%% Import data from text file.
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');
dataGonthier2error = readtable('Gonthier - Experiment 2 - Clean Data.csv', 'ReadVariableNames',true);

modelName = "RecallOverride";
model = @metaControlModelRecallOverride;
modelNoGo = @metaControlModelRecallOverrideNoGo;

% No Go
dataGonthier2_NoGo = dataGonthier2error;
dataGonthier2_NoGo{:,22:27} = 1 - dataGonthier2_NoGo{:,22:27}; % Transforming erros to accuracy
dataGonthier2_NoGo.Properties.VariableNames([22:27]) = {'AccAX','AccAY','AccBX','AccBY','AccAN','AccBN'}; % renaming variables

% Baseline
dataGonthier2 = dataGonthier2error;
dataGonthier2{:,8:11} = 1 - dataGonthier2{:,8:11};
dataGonthier2.Properties.VariableNames([8:11]) = {'AccAX','AccAY','AccBX','AccBY'}; % renaming variables

%% Experimental Design - cue-probe frequencies
fAX = 40; fAY = 10; fBX = 10; fBY = 40; fAN = 12; fBN = 12;
ftotal = fAX + fAY + fBX + fBY + fAN + fBN;
pAX = fAX/ftotal; pAY = fAY/ftotal; pBX = fBX/ftotal; pBY=fBY/ftotal; pAN = fAN/ftotal; pBN=fBN/ftotal;
p_cue_probe_noGo=[pAX, pAY, pBX, pBY, pAN, pBN];
p_cue_probe_baseline = [0.4 0.1 0.1 0.4];

accuracies_baseline = dataGonthier2{:,8:11};
accuracies_noGo = dataGonthier2_NoGo{:,22:27};
p_slip = 1 - mean(accuracies_baseline(:,4));
nr_subjects=size(dataGonthier2,1);
gamma = 1/3; 
random_inhibition = 0.7;

load = 1;
m = 1;
p_random_inhibition = 0.7;
maxalpha = 10;
trials_noGo = ftotal;
trials_baseline = fAX + fAY + fBX + fBY;

%% Fitting the Meta Control Model - Individual   %%
clear accs pars ll p_intentions optimal_cs p_recalls accs_noGo p_intentions_noGo optimal_cs_noGo p_recalls_noGo

control_different = 3; % all parameters different

for s=1:nr_subjects
    [pars(s,:),accs(s,:),ll(s), p_intentions(s,:), optimal_cs(s,:), p_recalls(s,:), accs_noGo(s,:), p_intentions_noGo(s,:), optimal_cs_noGo(s,:), p_recalls_noGo(s,:), bic(s)]= ...
    fitMetaControlModelNoGoSimultaneously(modelName, accuracies_baseline(s,[1:4]),accuracies_noGo(s,:),load,trials_baseline,trials_noGo,m,p_random_inhibition,p_cue_probe_baseline,p_cue_probe_noGo, p_slip,control_different);
end

BIC(:,1) = bic; 

%% plot accuracies
accs(:,[5:6]) = 0;
accuracies_baseline(:,[5:6]) = 0;

acc_pred_error_baseline = std(accs)./sqrt(size(accs,1));
acc_pred_error_noGo = std(accs_noGo)./sqrt(size(accs_noGo,1));
acc_obs_error_baseline = std(accuracies_baseline)./sqrt(size(accuracies_baseline,1));
acc_obs_error_noGo = std(accuracies_noGo)./sqrt(size(accuracies_noGo,1));

figure('units','normalized','outerposition',[0.2 0.2 0.5 0.65])
subplot(1,2,1),
y1 = [mean(accs)', mean(accs_noGo)'];
hBar = bar(y1,1);
err1 = [acc_pred_error_baseline', acc_pred_error_noGo'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
xlabel('Trial Type')
ylabel('Accuracy','FontSize',16)
title('Fitted','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY','AN','BN'},'FontSize',14)
legend('Baseline','No Go','FontSize',10)

subplot(1,2,2)
y1 = [mean(accuracies_baseline)', mean(accuracies_noGo)'];
hBar = bar(y1,1);
err1 = [acc_obs_error_baseline', acc_obs_error_noGo'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
xlabel('Trial Type')
ylabel('Accuracy','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY','AN','BN'},'FontSize',14)
legend('Baseline','No Go','FontSize',10, 'Position', [0.833 0.157 0.01 0.01])


%% testing differences
pars_noGo = pars(:,5:8);

% alpha 
[h,p,ci,stats] = ttest(pars(:,1),pars_noGo(:,1)) 

% alphaAX
[h,p,ci,stats] = ttest(pars(:,2),pars_noGo(:,2)) 
M_baseline = mean(pars(:,2))
SD_baseline = std(pars(:,2))
M_noGo = mean(pars_noGo(:,2))
SD_noGo = std(pars_noGo(:,2))

% delta_t
[h,p,ci,stats] = ttest(pars(:,3),pars_noGo(:,3)) 
M_baseline = mean(pars(:,3))
SD_baseline = std(pars(:,3))
M_noGo = mean(pars_noGo(:,3))
SD_noGo = std(pars_noGo(:,3))

% interference
[h,p,ci,stats] = ttest(pars(:,4),pars_noGo(:,4)) 


%% Predictions for No Go 
clear alphas alphasAX control_cost delta_ts interference pars_baseline fitted_accs
% we fitted our model’s parameters to baseline and then used our meta-control model to simulate how the accuracies
% should change when no-go trials are added
isNoGo = 0;
trials = sum(trials_baseline.*p_cue_probe_baseline);

for s=1:nr_subjects
    [pars_baseline(s,:),fitted_accs(s,:),ll(s), p_intentions(s,:), optimal_cs(s,:), p_recalls(s,:)]= ...
    fitMetaControlModel(modelName, isNoGo, accuracies_baseline(s,[1:4]),load,trials,m,p_random_inhibition,p_cue_probe_baseline, p_slip);
end   

alphas = [pars_baseline(:,1)];
alphasAX = [pars_baseline(:,2)];
control_cost = [pars_baseline(:,3)];
delta_ts=[pars_baseline(:,4)];
interference = [pars_baseline(:,5)];

% Predictions for no-go based on baseline fitted parameters
for s=1:nr_subjects
    [acc_pred_noGo(s,:), pred_p_intentions_noGo(s,:), pred_optimal_cs_noGo(s,:), pred_p_recalls_noGo(s,:)] = ...
     modelNoGo(alphas(s),alphasAX(s),gamma,load,control_cost(s),delta_ts(s),m,random_inhibition,p_cue_probe_noGo,p_slip);
end   

%% Plots accuracy (fitted baseline + predicted no-go)
fitted_accs(:,[5:6]) = 0; % pred fitted baseline
accuracies_baseline(:,[5:6]) = 0; % observed
acc_pred_error_baseline = std(fitted_accs)./sqrt(size(fitted_accs,1)); % pred no-go
acc_pred_error_noGo = std(acc_pred_noGo)./sqrt(size(acc_pred_noGo,1));


figure('units','normalized','outerposition',[0.2 0.2 0.5 0.65])
subplot(1,2,1),
y1 = [mean(fitted_accs)', mean(acc_pred_noGo)'];
hBar = bar(y1,1);
err1 = [acc_pred_error_baseline', acc_pred_error_noGo'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
xlabel('Trial Type')
ylabel('Accuracy','FontSize',16)
title('Predicted','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY','AN','BN'},'FontSize',14)
%legend('Baseline','No Go','FontSize',10)

subplot(1,2,2)
y1 = [mean(accuracies_baseline)', mean(accuracies_noGo)'];
hBar = bar(y1,1);
err1 = [acc_obs_error_baseline', acc_obs_error_noGo'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
xlabel('Trial Type')
ylabel('Accuracy','FontSize',16)
title('Observed','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY','AN','BN'},'FontSize',14)
legend('Baseline','No Go','FontSize',10, 'Position', [0.833 0.157 0.01 0.01])


% p_intention baseline vs no-go
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.65])
subplot(1,2,1),
y1 = [mean(p_intentions(:,[1,3]))', mean(pred_p_intentions_noGo(:,[1,3]))'];
hBar = bar(y1,1);
ylim([0,0.8])
xlabel('Trial Type')
ylabel('p_{intention}','FontSize',16)
title('Predicted','FontSize',16)
set(gca,'XTickLabel',{'A-trials','B-trials'},'FontSize',14)
legend('Baseline','No Go','FontSize',10)
