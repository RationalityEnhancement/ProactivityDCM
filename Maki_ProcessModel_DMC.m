%% Import data from text file.
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');
import_data_AXCPT;

%% Fitting the model - individually 
data_AXCPT = table2array(DataAXCPT(:,[2:3,6:13]));
experiment = AXCPTExperiment();
pAX = 0.7; pAY = 0.1; pBX = 0.1; pBY = 0.1; 
p_cue_probe = [pAX,pAY,pBX,pBY];
experiment.blocks(1).p_trial_type = p_cue_probe;

accuracies = data_AXCPT(:,3:6);
RTs = data_AXCPT(:,7:end);
reward = data_AXCPT(:,2);
cognitive_load = data_AXCPT(:,1);
trials = 150;
m = 1;
p_slip = 1-mean(accuracies(:,4));
nr_subcjets=size(DataAXCPT,1);
random_inhibition = 0.7;

%% p_intention and p_recall as free parameters
isNoGo = 0;

for s=1:nr_subcjets
    [parameters_by_participant(s,:), predicted_accs_by_participant(s,:), ll(s),bic(s)]= ...
    fitProcessModel_RecallOverride(accuracies(s,:),cognitive_load(s),trials, m,p_cue_probe,p_slip, isNoGo);
end


%% {lot predicted fully proactive (I=1) and fully reactive (I=0) with fitted p_recall
% Observed and estimated accuracies for reward = 0 and load = 1;
accuracies_reward0_load1 = accuracies(reward == 0 & cognitive_load ==1, :);
acc_obs_error = std(accuracies(reward == 0 & cognitive_load ==1, :))./sqrt(size(accuracies(reward == 0 & cognitive_load ==1, :),1));
predicted_accs_by_participant_reward0_load1 = predicted_accs_by_participant(reward == 0 & cognitive_load ==1, :);
acc_pred_error = std(predicted_accs_by_participant(reward == 0 & cognitive_load ==1, :))./sqrt(size(predicted_accs_by_participant(reward == 0 & cognitive_load ==1, :),1));


% mean p_recall for reward = 0 and load = 1
p_recall_reward0_load1 = mean(parameters_by_participant(reward == 0 & cognitive_load ==1, 2));

N_participants_total = 266;
N_trials_total = 150;
N=experiment.blocks(1).p_trial_type*N_participants_total*N_trials_total;
load =1;
m=1;
p_slip = 1-mean(accuracies_reward0_load1(:,4));

accuracies_p_intention1 = outselect(1, @processModelRecallOverride, 1, p_recall_reward0_load1,load,m,p_cue_probe,p_slip);
accuracies_p_intention0 = outselect(1, @processModelRecallOverride, 0,  p_recall_reward0_load1,load,m,p_cue_probe,p_slip);


%% Fully Proactive vs Fully Reactive with p_recall = 0.9281
figure()
subplot(1,2,1)
bar([accuracies_p_intention1',mean(accuracies_reward0_load1)',accuracies_p_intention0'],1)
ylim([0.5,1])
legend('P_{intention} = 1','People','P_{intention} = 0', 'FontSize',8)
set(gca,'XTickLabels',[{'AX', 'AY', 'BX','BY'}],'FontSize',14)
ylabel('Accuracy','FontSize',16)
xlabel('Trial Type','FontSize',16)
% Predicted accuracies vs. Observed accuracy for 
subplot(1,2,2)
y1 = [mean(predicted_accs_by_participant_reward0_load1)',mean(accuracies_reward0_load1)'];
hBar = bar(y1,1);
err1 = [acc_pred_error', acc_obs_error'];
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
hold on
hEB=errorbar(xBar,y1,err1,'k.');
ylim([0.5,1])
b(1).FaceColor='flat';
b(1).CData=[0,0.5,0]
ylim([0.5,1])
legend('Model Fit','People','FontSize',10)
set(gca,'XTickLabels',[{'AX', 'AY', 'BX','BY'}],'FontSize',14)
ylabel('Accuracy','FontSize',18)
xlabel('Trial Type','FontSize',16)

%%
mean(parameters_by_participant(reward == 0 & cognitive_load ==1, :))
std(parameters_by_participant(reward == 0 & cognitive_load ==1, :))

min(parameters_by_participant(reward == 0 & cognitive_load ==1, :))
max(parameters_by_participant(reward == 0 & cognitive_load ==1, :))