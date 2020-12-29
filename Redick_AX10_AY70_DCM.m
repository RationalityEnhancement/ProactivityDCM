%% Import data from text file
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');

dataRedick = readtable('Redick2014.csv', 'ReadVariableNames',true);
dataRedick = dataRedick(dataRedick.Version == 10, :);
data_redick = table2array(dataRedick(dataRedick.Version == 10,[3,5,6,7,8]));

modelName = "RecallOverride";
model = @metaControlModelRecallOverride;
isNoGo = 0;

%% Experimental design - cue-probe frequencies
experiment = AXCPTExperiment();
pAX = 0.1; pAY = 0.7; pBX = 0.1; pBY = 0.1;
pA = pAX+pAY/(pAX+pAY+pBX+pBY); 
pB = pBX+pBY/(pAX+pAY+pBX+pBY);
p_cue_probe = [pAX,pAY,pBX,pBY];
experiment.blocks(1).p_trial_type = p_cue_probe;

accuracies = data_redick(:,[2:5]);
load = [2, 1]; % 2 for participatns with low WM and 1 for high WM
p_slip = 1-mean(accuracies(:,4));
trials = 400;
nr_subjects=size(data_redick,1);
gamma=1/3;
m = 1;
p_random_inhibition = 0.7;

maxalpha = 10;


for s=1:nr_subjects 
    if data_redick(s,1) == 0
        cognitive_load(s) = 2;
    else
        cognitive_load(s) = 1;
    end
end


%% Fiting the Meta Control Model - Individual   %%

for s=1:nr_subjects
   [pars(s,:), fitted_accs(s,:), ll(s), fitted_p_intentions(s,:), fitted_optimal_cs(s,:), fitted_p_recalls(s,:), bic(s,:)]= ...
   fitMetaControlModel(modelName, isNoGo, accuracies(s,:), cognitive_load(s), trials, m, p_random_inhibition, p_cue_probe, p_slip);
end

%% Plot fitted and observed accuracies 
for l=1:2
    accuracy_fitted(:,l) = mean(fitted_accs(cognitive_load==load(l),:));
    acc_pred_error(:,l) = std(fitted_accs(cognitive_load==load(l),:))./sqrt(size(fitted_accs(cognitive_load==load(l),:),1));
    accuracy_condition(:,l) = mean(accuracies(cognitive_load==load(l),:));
    acc_obs_error(:,l) = std(accuracies(cognitive_load==load(l),:))./sqrt(size(accuracies(cognitive_load==load(l),:),1));
end

figure('units','normalized','outerposition',[0.2 0.2 0.45 0.65])
subplot(1,2,1),
y1 = squeeze(accuracy_fitted);
hBar = bar(y1,1);
err1 = acc_pred_error;
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
ylabel('Accuracy','FontSize',16)
title('Fitted','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

subplot(1,2,2)
y1 = squeeze(accuracy_condition);
hBar = bar(y1,1);
err1 = acc_obs_error;
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
ylabel('Accuracy','FontSize',16)
xlabel('Trial Type','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)
legend('Low WM','High WM','FontSize',10, 'Position', [0.822 0.157 0.01 0.01])

%% Mean fitted parameters to use in the predictions
mean_alpha = [mean(pars(:,1))] 
mean_alphaAX = [mean(pars(:,2))] 
mean_control_cost = [mean(pars(:,3))]
mean_delta_t = [mean(pars(:,4))]
mean_interference = [mean(pars(:,5))]


%% Predictions for the meta control model - AX-CPT 40-40-10-10
%% Step 1: proactive intention setting - CUE
% Probability of correct response according to each strategy 
p_correct_habitual=[pAX/(pAX+pBX), 1, 1-pAX/(pAX+pBX), 1]*(1-p_slip) + ...
                     [1-pAX/(pAX+pBX), 0, pAX/(pAX+pBX), 0]*(p_slip); % according to Hernstein's matching law

for l=1:numel(load)
    p_correct_proactive(l,:) = [pAX/pA - 0.05*(load(l)-1), ...
                               1-pAX/(pAX+pAY) + 0.05*(load(l)-1), ...
                               (pBX+pBY)/pB - 0.05*(load(l)-1), ...
                               (pBX+pBY)/pB - 0.05*(load(l)-1)]*(1-p_slip) + ...
                               p_slip*[(1-pAX/pA) + 0.05*(load(l)-1), ...
                               (1-pAY/pA) - 0.05*(load(l)-1), ...
                               1-((pBX+pBY)/pB) + 0.05*(load(l)-1), ...
                               1-((pBX+pBY)/pB) + 0.05*(load(l)-1)];
end            
                   
%% benefit of using proactive control instead of habitual
delta_acc = p_correct_proactive-p_correct_habitual

% Probability of each trial type given a specific cue or probe
p_given_A=[pAX/(pAX+pAY), pAY/(pAX+pAY), 0, 0]; % probability of trial type given A
p_given_B=[0, 0, pBX/(pBX+pBY), pBY/(pBX+pBY)]; % probability of trial type given B
p_given_X=[pAX/(pAX+pBX), 0, pBX/(pAX+pBX), 0]; % probability of trial type given X
p_given_Y=[0, pAY/(pAY+pBY), 0, pBY/(pAY+pBY)]; % probability of trial type given Y

% benefit of using proactive control for each trial type
for l=1:numel(load)
        E_delta_acc_A(l,:) = dot(delta_acc(l,:),p_given_A);
        E_delta_acc_B(l,:) = dot(delta_acc(l,:),p_given_B);
        E_delta_acc_X(l,:) = dot(delta_acc(l,:),p_given_X);
        E_delta_acc_Y(l,:) = dot(delta_acc(l,:),p_given_Y);
end

% Overall benefit of proactive control over habitual for each cue considering cost
net_benefit_A = @(ratio,l) E_delta_acc_A(l,:)*ratio+mean_delta_t(1)-gamma; 
net_benefit_B = @(ratio,l) E_delta_acc_B(l,:)*ratio+mean_delta_t(1)-gamma;

%% Cost-Benefit analysis of proactivity for each cue
choose_proactivity_A = @(ratio,l) net_benefit_A(ratio,l)>0;
choose_proactivity_B = @(ratio,l) net_benefit_B(ratio,l)>0;

% Plot benefit for each cue for different Alphas
ratios = linspace(0,20,101);

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
subplot(1,2,1)
plot(ratios,zeros(1,101),'k-'),hold on
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Net Benefit of Proactive Control','FontSize',16)
set(gca,'FontSize',14,'Position',[0.1 .2 0.33 0.70])
xlim([0,20]),ylim([-10,10])
for l=1:numel(load) 
    plot(ratios,net_benefit_A(ratios,l),'LineWidth',3), hold on
end
title('Cost-Benefit Analysis for A-trials')

subplot(1,2,2)
plot(ratios,zeros(1,101),'k-'),hold on
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Net Benefit of Proactive Control','FontSize',16)
xlim([0,20]),ylim([-10,10])
set(gca,'FontSize',14, 'Position',[0.6 .2 0.33 0.7])
for l=1:numel(load) 
    plot(ratios,net_benefit_B(ratios,l),'LineWidth',3), hold on
end
legend({'no benefit','Low WM', 'High WM'}, 'Position',[0.3 0.7 0.01 0.01])
title('Cost-Benefit Analysis for B-trials')

%% Transform net benefit to fit between 0 an 1 (Probability)
p_proactive_A = @(ratio,n) sigmoid(net_benefit_A(ratio,n))
p_proactive_B = @(ratio,n) sigmoid(net_benefit_B(ratio,n))

% Plot Probability to engange in Proactive Control for each cue 
figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6])
subplot(1,2,1)
for l=1:numel(load)
    plot(ratios,p_proactive_A(ratios,load(l)),'LineWidth',3),hold on 
end
title('p_{intention} in response to A','FontSize',16)
xlabel('Reward parameter \alpha','FontSize',16)
ylabel('Probability of Proactive Intention Setting','FontSize',16)
xlim([0,20])
ylim([0,1])
set(gca,'FontSize',14)
%legend({'Low WM', 'High WM'})

subplot(1,2,2)
for l=1:numel(load)
    plot(ratios,p_proactive_B(ratios,load(l)),'LineWidth',3),hold on
end
title('p_{intention} in response to B','FontSize',16)
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Probability of Proactive Intention Setting','FontSize',16)
xlim([0,20])
ylim([0,1])
set(gca,'FontSize',14)
legend({'Low WM', 'High WM'},'Position',[0.8 0.3 0.01 0.01])

% Probability to set a proactive intention for each cue (only traditional cognitive load)
figure('units','normalized','outerposition',[0.3 0.2 0.3 0.6])
for l=1:numel(load)
    plot(ratios,p_proactive_A(ratios,l),'-','LineWidth',3),hold on 
end
plot(ratios,p_proactive_B(ratios,1),':','color',[0, 0.4470, 0.7410],'LineWidth',3)
plot(ratios,p_proactive_B(ratios,2),':','color',[0.8500, 0.3250, 0.0980],'LineWidth',3)
%plot(ratios,p_proactive_B(ratios,3),':','color',[0.9290, 0.6940, 0.1250],'LineWidth',3)
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Probability to set intention','FontSize',16)
title(['p_{intention} assuming u_{\Delta{}t}=', num2str(mean_delta_t(1),'%.2f')])
xlim([0,20])
set(gca,'FontSize',14)
legend({'cue = A, Low WM','cue = A, High WM', 'cue = B, Low WM', 'cue = B, High WM'},'FontSize',10,'Position',[0.7 0.5 0.01 0.01])

%% Decision 2: Deciding wether to recall the rules and cue 
m = 1;
for l = 1:numel(load)
    p_correct_recall(l,:) = [m-0.05*(load(l)-1), m-0.05*(load(l)-1), m-0.05*(load(l)-1), m-0.05*(load(l)-1)]*(1-p_slip)...
    + p_slip*[1-m-0.05*(load(l)-1), 1-m-0.05*(load(l)-1), 1-m-0.05*(load(l)-1), 1-m-0.05*(load(l)-1)];
end

delta_acc_recall = p_correct_recall-p_correct_habitual;

% benefit of using recalling the rules for each trial type
for l = 1:numel(load)
    E_delta_acc_recall_A(l) = dot(delta_acc_recall(l,:),p_given_A);
    E_delta_acc_recall_B(l) = dot(delta_acc_recall(l,:),p_given_B);
    E_delta_acc_recall_X(l) = dot(delta_acc_recall(l,:),p_given_X);
    E_delta_acc_recall_Y(l) = dot(delta_acc_recall(l,:),p_given_Y);
end

% Overall benefit of recalling the rules over habitual for each cue considering cost
net_benefit_recall_X = @(ratio,l) E_delta_acc_recall_X(l)*ratio-mean_delta_t(1)-gamma
net_benefit_recall_Y = @(ratio,l) E_delta_acc_recall_Y(l)*ratio-mean_delta_t(1)-gamma

%% Cost-Benefit analysis of recalling the rules for each cue
% Plot benefit for each cue for different alphas
ratios = linspace(0,20,101);

figure('units','normalized','outerposition',[0.2 0.2 0.67 0.6])
subplot(1,2,1)
plot(ratios,zeros(1,101),'k-'),hold on
xlabel('Reward parameter \alpha','FontSize',16)
ylabel('Net Benefit of p_{recall}','FontSize',16)
set(gca,'FontSize',14)
xlim([0,20]),ylim([-4,4])
for l=1:numel(load) 
    plot(ratios,net_benefit_recall_X(ratios,load(l)),'LineWidth',3), hold on
end
title('Cost-Benefit Analysis of p_{recall} for X-probes')

subplot(1,2,2)
plot(ratios,zeros(1,101),'k-'),hold on
xlabel('Reward parameter \alpha','FontSize',16)
ylabel('Net Benefit of p_{recall}','FontSize',16)
xlim([0,20]),ylim([-4,4])
set(gca,'FontSize',14)
for l=1:numel(load) 
    plot(ratios,net_benefit_recall_Y(ratios, l),'LineWidth',3), hold on
end
legend({'no benefit','Low WM', 'High WM'},'Position',[0.82 0.5 0.01 0.01])
title('Cost-Benefit Analysis of p_{recall} for Y-probes')


%% Transform net benefit of recalling to fit between 0 an 1 (Probability)
p_recall_X = @(ratio,l) sigmoid(net_benefit_recall_X(ratio,l))
p_recall_Y = @(ratio,l) sigmoid(net_benefit_recall_Y(ratio,l))

% Plot Probability to engange in Proactive Control for each cue 
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.6])
subplot(1,2,1)
for l=1:numel(load)
    plot(ratios,p_recall_X(ratios,l),'LineWidth',3),hold on 
end
title('p(recall) for X trials','FontSize',16)
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Probability of Recall','FontSize',16)
xlim([0,20])
ylim([0,1])
set(gca,'FontSize',14)
%legend({'Low WM', 'High WM'})

subplot(1,2,2)
for l=1:numel(load)
    plot(ratios,p_recall_Y(ratios,l),'LineWidth',3),hold on
end
title('p(recall) for Y trials','FontSize',16)
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Probability of Recall','FontSize',16)
xlim([0,10])
ylim([0,0.7])
set(gca,'FontSize',14)
legend({'Low WM', 'High WM'})

% Probability to recall for each cue (only traditional cognitive load)
figure('units','normalized','outerposition',[0.2 0.2 0.4 0.6])
for l=1:numel(load)
    plot(ratios,p_recall_X(ratios,l),'-','LineWidth',3),hold on 
end
plot(ratios,p_recall_Y(ratios,1),':','color',[0, 0.4470, 0.7410],'LineWidth',3)
plot(ratios,p_recall_Y(ratios,2),':','color',[0.8500, 0.3250, 0.0980],'LineWidth',3)
xlabel('Reward parameter alpha','FontSize',16)
ylabel('Probability of Recall','FontSize',16)
xlim([0,20])
ylim([0,1])
set(gca,'FontSize',14)
title(['p(recall) for u_{\Delta{}t}=',num2str(mean_delta_t(1), '%.2f'),' and {\delta}=', num2str(mean_control_cost(1), '%.2f')]) %'interpreter','latex','FontSize',16)
legend({'cue = X, Low WM','cue = X, High WM','cue = Y, Low WM','cue = Y, High WM'},'FontSize',10,'Position',[0.26 0.82 0.01 0.01])


%% Comparing AX accuracy between load conditions
mean(fitted_accs(dataRedick.WMC==0, :))
mean(fitted_accs(dataRedick.WMC==1, :))
std(fitted_accs(dataRedick.WMC==0, :))
std(fitted_accs(dataRedick.WMC==1, :))
[h,p,ci,stats]=ttest2(fitted_accs(dataRedick.WMC==0, :),fitted_accs(dataRedick.WMC==1, :))