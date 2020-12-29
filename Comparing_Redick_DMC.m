%% comparing Accuracies between redicks datasets
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');

dataRedick = readtable('Redick2014.csv', 'ReadVariableNames',true);
data_redick70 = table2array(dataRedick(dataRedick.Version == 70,[3,5,6,7,8]));
data_redick40 = table2array(dataRedick(dataRedick.Version == 40,[3,5,6,7,8]));
data_redick10 = table2array(dataRedick(dataRedick.Version == 10,[3,5,6,7,8]));

modelName = "RecallOverride";
model = @metaControlModelRecallOverride;

%% Fitting - Redick 70-10-10-10
experiment = AXCPTExperiment();
pAX = 0.7; pAY = 0.1; pBX = 0.1; pBY = 0.1; 
p_cue_probe = [pAX,pAY,pBX,pBY];
accuracies70 = data_redick70(:,[2:5]);
p_slip = 1-mean(accuracies70(:,4));
trials = 400;
nr_subjects=size(data_redick70,1);
m = 1;
p_random_inhibition = 0.7;
gamma = 1/3;
isNoGo = 0;
maxalpha = 10;

%% Fitting Meta Control over Proactive and Reactive Control
for s=1:nr_subjects 
    if data_redick70(s,1) == 0
        cognitive_load(s) = 2; % 2 for participatns with low WM and 1 for high WM
    else
        cognitive_load(s) = 1;
    end
end

for s=1:nr_subjects
   [pars_70(s,:), fitted_accs_70(s,:), ll_70(s), fitted_p_intentions_70(s,:), fitted_optimal_cs_70(s,:), fitted_p_recalls_70(s,:)]= ...
   fitMetaControlModel(modelName, isNoGo, accuracies70(s,:), cognitive_load(s), trials,m,p_random_inhibition, p_cue_probe, p_slip);
end

%% Comparing Accuracy on AX trials
mean(fitted_accs_70(cognitive_load==1,:)), std(fitted_accs_70(cognitive_load==1,:))
mean(fitted_accs_70(cognitive_load==2,:)), std(fitted_accs_70(cognitive_load==2,:))
[h,p,ci,stats] = ttest2(fitted_accs_70(cognitive_load==1,:), fitted_accs_70(cognitive_load==2,:))


%% Fitting - Redick 40
pAX = 0.4; pAY = 0.4; pBX = 0.1; pBY = 0.1; 
p_cue_probe = [pAX,pAY,pBX,pBY];
accuracies40 = data_redick40(:,[2:5]);
p_slip = 1-mean(accuracies40(:,4));
trials = 400;
nr_subjects=size(data_redick40,1);


%% Fitting Meta Control over Proactive and Reactive Control
for s=1:nr_subjects 
    if data_redick40(s,1) == 0
        cognitive_load(s) = 2; % 2 for participatns with low WM and 1 for high WM
    else
        cognitive_load(s) = 1;
    end
end

for s=1:nr_subjects
   [pars_40(s,:), fitted_accs_40(s,:), ll_40(s), fitted_p_intentions_40(s,:), fitted_optimal_cs_40(s,:), fitted_p_recalls_40(s,:)]= ...
   fitMetaControlModel(modelName, isNoGo, accuracies40(s,:), cognitive_load(s), trials,m,p_random_inhibition, p_cue_probe, p_slip);
end

%% Comparing Accuracy on AX trials
mean(fitted_accs_40(cognitive_load==1,:)), std(fitted_accs_40(cognitive_load==1,:))
mean(fitted_accs_40(cognitive_load==2,:)), std(fitted_accs_40(cognitive_load==2,:))
[h,p,ci,stats] = ttest2(fitted_accs_40(cognitive_load==1,:), fitted_accs_40(cognitive_load==2,:))


%% Fiting Redick 10
pAX = 0.1; pAY = 0.7; pBX = 0.1; pBY = 0.1; 
p_cue_probe = [pAX,pAY,pBX,pBY];
accuracies10 = data_redick10(:,[2:5]);
p_slip = 1-mean(accuracies10(:,4));
trials = 400;
nr_subjects=size(data_redick10,1);

%% Fitting Meta Control over Proactive and Reactive Control
for s=1:nr_subjects 
    if data_redick10(s,1) == 0
        cognitive_load(s) = 2;
    else
        cognitive_load(s) = 1;
    end
end

for s=1:nr_subjects
   [pars_10(s,:), fitted_accs_10(s,:), ll_10(s), fitted_p_intentions_10(s,:), fitted_optimal_cs_10(s,:), fitted_p_recalls_10(s,:)]= ...
   fitMetaControlModel(modelName, isNoGo, accuracies10(s,:), cognitive_load(s), trials,m,p_random_inhibition, p_cue_probe, p_slip);
end
%% Comparing Accuracy on AX trials
mean(fitted_accs_10(cognitive_load==1,:)), std(fitted_accs_10(cognitive_load==1,:))
mean(fitted_accs_10(cognitive_load==2,:)), std(fitted_accs_10(cognitive_load==2,:))
[h,p,ci,stats] = ttest2(fitted_accs_10(cognitive_load==1,:), fitted_accs_10(cognitive_load==2,:))


%% Predicitions for different trial types using fitted from 70-10-10-10 condition with High WM participants
pars_70_h = pars_70(cognitive_load==1,:);
alphas = [pars_70_h(:,1)];
alphasAX = [pars_70_h(:,2)];
delta_ts = [pars_70_h(:,4)];
interference = [pars_70_h(:,5)];
load = 1;
trials = 400; 

% AX-CPT 40-40-10-10
p_cue_probe_40 = [.4 .4 .1 .1];
for s=1:size(pars_70_h,1)
    [acc_pred_40(s,:), pred_p_intentions_40(s,:), pred_optimal_cs_40(s,:), pred_p_recalls_40(s,:)] = ...
     model(alphas(s),alphasAX(s),gamma,load,delta_ts(s),interference(s),m,p_random_inhibition,p_cue_probe_40,p_slip);
end

% AX-CPT 10-70-10-10
p_cue_probe_10 = [.1 .7 .1 .1];
for s=1:size(pars_70_h,1)
    [acc_pred_10(s,:), pred_p_intentions_10(s,:), pred_optimal_cs_10(s,:), pred_p_recalls_10(s,:)] = ...
     model(alphas(s),alphasAX(s),gamma,load,delta_ts(s),interference(s),m,p_random_inhibition,p_cue_probe_10,p_slip);
end

%% Plot predicted vs observed accuracies
M70 = mean(fitted_accs_70(cognitive_load == 1,:));
SEM70 = std(fitted_accs_70(cognitive_load==1,:))./sqrt(size(fitted_accs_70(cognitive_load==1,:),1));
M40 = mean(acc_pred_40);
SEM40 = std(acc_pred_40)./sqrt(size(acc_pred_40,1));
M10 =  mean(acc_pred_10);
SEM10 = std(acc_pred_10)./sqrt(size(acc_pred_10,1));


figure('units','normalized','outerposition',[0.2 0.2 0.65 0.6])
subplot(1,3,1),
x = [1 2 3 4];
y1 = M70;
hBar = bar(x,y1);
err1 = SEM70;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Predicted','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

subplot(1,3,2)
x = [1 2 3 4];
y1 = M40;
hBar = bar(x,y1);
err1 = SEM40;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Predicted','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

subplot(1,3,3)
x = [1 2 3 4];
y1 = M10;
hBar = bar(x,y1);
err1 = SEM10;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Predicted','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)


% observed
obsM70 = mean(accuracies70(cognitive_load == 1,:));
obsSEM70 = std(accuracies70(cognitive_load==1,:))./sqrt(size(accuracies70(cognitive_load==1,:),1));
obsM40 = mean(accuracies40(cognitive_load == 1,:));
obsSEM40 = std(accuracies40(cognitive_load==1,:))./sqrt(size(accuracies40(cognitive_load==1,:),1));
obsM10 =  mean(accuracies10);
obsSEM10 = std(accuracies10(cognitive_load==1,:))./sqrt(size(accuracies10(cognitive_load==1,:),1));


figure('units','normalized','outerposition',[0.2 0.2 0.65 0.6])
subplot(1,3,1),
x = [1 2 3 4];
y1 = obsM70;
hBar = bar(x,y1);
err1 = obsSEM70;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

subplot(1,3,2)
x = [1 2 3 4];
y1 = obsM40;
hBar = bar(x,y1);
err1 = obsSEM40;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

subplot(1,3,3)
x = [1 2 3 4];
y1 = obsM10;
hBar = bar(x,y1);
err1 = obsSEM10;
hold on
hEB=errorbar(x,y1,err1,'k.');
ylim([0.6,1])
yticks([.6 .7 .8 .9 1])
ylabel('Accuracy','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',experiment.trial_types,'FontSize',14)

