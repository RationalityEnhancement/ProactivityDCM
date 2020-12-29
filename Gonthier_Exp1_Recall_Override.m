%% Import data from text file
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');
dataGonthier1error = readtable('Gonthier - Experiment 1 - Clean Data.csv', 'ReadVariableNames',true);

modelName = "RecallOverride";
model = @metaControlRecallOverride;

isNoGo = 0;
load = 1;
m = 1;
p_random_inhibition = 0.7;

dataGonthier1 = dataGonthier1error;
dataGonthier1{:,7:10} = 1 - dataGonthier1{:,7:10}; % Transforming erros to accuracy
dataGonthier1.Properties.VariableNames([7:10]) = {'AccAX','AccAY','AccBX','AccBY'}; % renaming variables

%% to change according to each dataset
experiment = AXCPTExperiment();
pAX = 0.4; pAY = 0.1; pBX = 0.1; pBY = 0.4;
p_cue_probe=[pAX, pAY, pBX, pBY];
accuracies = dataGonthier1{:,7:10};
accuracies_baseline = accuracies(dataGonthier1.Condition == 1, :);
accuracies_training = accuracies(dataGonthier1.Condition == 2, :);

p_slip = 1 - mean(accuracies(:,4));
nr_subjects=size(accuracies,1)/2;

trials_baseline = 200;
trials_training = 150;
experiment.blocks(1).p_trial_type = [pAX,pAY,pBX,pBY];


%% Fitting the Meta Control Model - Individual  %%
for s=1:nr_subjects
    [pars(s,:),accs(s,:),ll(s), p_intentions(s,:), optimal_cs(s,:), p_recalls(s,:)]= ...
    fitMetaControlModel(modelName, isNoGo, accuracies_baseline(s,:),load,trials_baseline,m,p_random_inhibition,p_cue_probe, p_slip);

    [pars_training(s,:),accs_training(s,:),ll_training(s), p_intentions_training(s,:), optimal_cs_training(s,:), p_recalls_training(s,:)]= ...
    fitMetaControlModel(modelName, isNoGo, accuracies_training(s,:),load,trials_training,m,p_random_inhibition,p_cue_probe, p_slip);
end


%% plot accuracies
acc_pred_error_baseline = std(accs)./sqrt(size(accs,1));
acc_pred_error_training = std(accs_training)./sqrt(size(accs_training,1));
acc_obs_error_baseline = std(accuracies_baseline)./sqrt(size(accuracies_baseline,1));
acc_obs_error_training = std(accuracies_training)./sqrt(size(accuracies_training,1));


figure('units','normalized','outerposition',[0.2 0.2 0.4 0.65])
subplot(1,2,1),
y1 = [mean(accs)', mean(accs_training)'];
hBar = bar(y1,1);
err1 = [acc_pred_error_baseline', acc_pred_error_training'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
xlabel('Trial Type')
ylabel('Accuracy','FontSize',16)
title('Fitted','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY'},'FontSize',14)

subplot(1,2,2)
y1 = [mean(accuracies_baseline)', mean(accuracies_training)'];
hBar = bar(y1,1);
err1 = [acc_obs_error_baseline', acc_obs_error_training'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
ylabel('Accuracy','FontSize',16)
xlabel('Trial Type')
title('Observed','FontSize',16)
set(gca,'XTickLabel',{'AX','AY','BX','BY'},'FontSize',14)
legend('Baseline','Training','FontSize',10, 'Position', [0.815 0.16 0.01 0.01])


%% testing differences
% alpha 
[h,p,ci,stats] = ttest(pars(:,1),pars_training(:,1)) 

% alphaAX
[h,p,ci,stats] = ttest(pars(:,2),pars_training(:,2)) 

% delta_t
[h,p,ci,stats] = ttest(pars(:,4),pars_training(:,4)) 

% interference
[h,p,ci,stats] = ttest(pars(:,5),pars_training(:,5)) 

% mean and std for delta_t across conditions
mean(pars(:,4))
std(pars(:,4))
mean(pars_training(:,4))
std(pars_training(:,4))

