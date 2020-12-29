%% Compare DMC model with alternative meta control models

% Import data from text file.
addpath('C:\Users\giwama\Documents\GitHub\Rationality-Enhancement-Toolbox-master\MatlabToolbox')
addpath('C:\Users\giwama\Nextcloud\Proactivity\data');
addpath('C:\Users\giwama\Nextcloud\Proactivity\OSF2\functions');
dataGonthier2error = readtable('Gonthier - Experiment 2 - Clean Data.csv', 'ReadVariableNames',true);

modelName1 = "RecallOverride"; % DMC
modelName2 = "InhibitionRecall"; % Extended Model
modelName3 = "NoInhibition"; % Exclusivity without Inhibition
modelName4 = "InhibitionHabitual"; % Exclusivity with Inhibition
isNoGo = 1;

% Transforming erros to accuracy
% No Go
dataGonthier2_NoGo = dataGonthier2error;
dataGonthier2_NoGo{:,22:27} = 1 - dataGonthier2_NoGo{:,22:27};
dataGonthier2_NoGo.Properties.VariableNames([22:27]) = {'AccAX','AccAY','AccBX','AccBY','AccAN','AccBN'}; % renaming variables

% Baseline
dataGonthier2 = dataGonthier2error;
dataGonthier2{:,8:11} = 1 - dataGonthier2{:,8:11};
dataGonthier2.Properties.VariableNames([8:11]) = {'AccAX','AccAY','AccBX','AccBY'}; % renaming variables

%% Experimental design - cue-probe frequencies
fAX = 40; fAY = 10; fBX = 10; fBY = 40; fAN = 12; fBN = 12;
accuracies_baseline = dataGonthier2{:,8:11};
accuracies_noGo = dataGonthier2_NoGo{:,22:27};
load = 1;
p_slip = 1 - mean(accuracies_baseline(:,4));
nr_subjects=size(dataGonthier2,1);

%experiment = AXCPTExperiment();
ftotal = fAX + fAY + fBX + fBY + fAN + fBN;
pAX = fAX/ftotal; pAY = fAY/ftotal; pBX = fBX/ftotal; pBY=fBY/ftotal; pAN = fAN/ftotal; pBN=fBN/ftotal;
p_cue_probe_noGo=[pAX, pAY, pBX, pBY, pAN, pBN];
trials_noGo = ftotal;

m = 1;
p_random_inhibition = 0.7;

%% MODEL 1: Recall-Override 
for s=1:nr_subjects
    [pars_M1(s,:),accs_M1(s,:),ll_M1(s), p_intentions_M1(s,:), optimal_cs_M1(s,:), p_recalls_M1(s,:), bic_M1(s)]= ...
    fitMetaControlModel(modelName1, isNoGo, accuracies_noGo(s,:),load,trials_noGo,m,p_random_inhibition,p_cue_probe_noGo, p_slip);
end

BIC(:,1) = bic_M1; 

%% MODEL 2: Extendend Model 
for s=1:nr_subjects
    [pars_M2(s,:),accs_M2(s,:),ll_M2(s), p_intentions_M2(s,:), optimal_cs_M2(s,:), p_recalls_M2(s,:), bic_M2(s)]= ...
    fitMetaControlModel(modelName2, isNoGo, accuracies_noGo(s,:),load,trials_noGo,m,p_random_inhibition,p_cue_probe_noGo, p_slip);
end

BIC(:,2) = bic_M2; 

%% Model 3: Without Inhibition
for s=1:nr_subjects
    [pars_M3(s,:),accs_M3(s,:),ll_M3(s), p_intentions_M3(s,:), optimal_cs_M2(s,:), p_recalls_M3(s,:), bic_M3(s)]= ...
    fitMetaControlModel(modelName3, isNoGo,accuracies_noGo(s,:),load,trials_noGo,m,p_random_inhibition,p_cue_probe_noGo, p_slip);
end

BIC(:,3) = bic_M3; 

%% Model 4: If Inhibition, Habitual Response
for s=1:nr_subjects
    [pars_M4(s,:),accs_M4(s,:),ll_M4(s), p_intentions_M4(s,:), optimal_cs(s,:), p_recalls_M4(s,:), bic_M4(s)]= ...
    fitMetaControlModel(modelName4, isNoGo, accuracies_noGo(s,:),load,trials_noGo,m,p_random_inhibition,p_cue_probe_noGo, p_slip);
end

BIC(:,4) = bic_M4; 


%% Comparing BICs
BICdiff(:,1) = BIC(:,1)-BIC(:,1);
BICdiff(:,2) = BIC(:,1)-BIC(:,2);
BICdiff(:,3) = BIC(:,1)-BIC(:,3);
BICdiff(:,4) = BIC(:,1)-BIC(:,4);

for c=1:size(BIC,2)
    for s=1:nr_subjects 
        if BICdiff(s,c) >= -2 && BICdiff(s,c) < 0
           BICcomp(s,c) = -.5;
        elseif BICdiff(s,c) >= 0 && BICdiff(s,c) < 2
           BICcomp(s,c) = .5;
        elseif BICdiff(s,c) >= 2 && BICdiff(s,c) < 6
           BICcomp(s,c) = 1;
        elseif BICdiff(s,c) >= 6 && BICdiff(s,c) < 10
           BICcomp(s,c) = 2;
        elseif BICdiff(s,c) >= 10
            BICcomp(s,c) = 3;
        elseif BICdiff(s,c) >= -6 && BICdiff(s,c) < -2
            BICcomp(s,c) = -1;
       elseif BICdiff(s,c) >= -10 && BICdiff(s,c) < -6
            BICcomp(s,c) = -2;
       elseif BICdiff(s,c) < -10
            BICcomp(s,c) = -3;  
        end
     end      
end


tabulate(BICcomp(:,2))
tabulate(BICcomp(:,3))
tabulate(BICcomp(:,4))

%% LL
LL(:,1) = ll_M1;
LL(:,2) = ll_M2;
LL(:,3) = ll_M3;
LL(:,4) = ll_M4;

LLdiff(:,1) = LL(:,1)-LL(:,1);
LLdiff(:,2) = LL(:,1)-LL(:,2);
LLdiff(:,3) = LL(:,1)-LL(:,3);
LLdiff(:,4) = LL(:,1)-LL(:,4);

LLdiff = -LLdiff;

for c=1:size(LL,2)
    for s=1:nr_subjects 
        if LLdiff(s,c) >= -2 && LLdiff(s,c) < 0
           LLcom(s,c) = -.5;
        elseif LLdiff(s,c) >= 0 && LLdiff(s,c) < 2
           LLcom(s,c) = .5;
        elseif LLdiff(s,c) >= 2 && LLdiff(s,c) < 6
           LLcom(s,c) = 1;
        elseif LLdiff(s,c) >= 6 && LLdiff(s,c) < 10
           LLcom(s,c) = 2;
        elseif LLdiff(s,c) >= 10
            LLcom(s,c) = 3;
        elseif LLdiff(s,c) >= -6 && LLdiff(s,c) < -2
            LLcom(s,c) = -1;
       elseif LLdiff(s,c) >= -10 && LLdiff(s,c) < -6
            LLcom(s,c) = -2;
       elseif LLdiff(s,c) < -10
            LLcom(s,c) = -3;  
        end
     end      
end

tabulate(LLcom(:,2))
