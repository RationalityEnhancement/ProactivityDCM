classdef AXCPTExperiment
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        context_letters
        probe_letters
        stimuli
        trial_types
        blocks =[struct('nr_trials',50,'p_trial_type',[]),struct('nr_trials',50,'p_trial_type',[])]
        nr_blocks = 2
        block_order
        block_types        
    end
    
    methods
        function obj = AXCPTExperiment()                   
            %AXCPTExperiment: Constructs an instance of an experiment with the AX-CPT task.            
            
            
            %stimuli format: trial.stimulus={context letter,probe letter},
            obj.context_letters = {'A','B'};
            obj.probe_letters = {'X', 'Y'};
            %B and Y could be any of the following letters: B, C, E, F, H, I, J, K, L, M, O, P, R, S, U
            
            obj.trial_types = {'AX','AY','BX','BY'};
            
            block.nr_trials = 50;
            block.p_trial_type=[0.70,0.10,0.10,0.10];
            
            
            obj.block_types = {'normal','reward','load','load & reward'};
            
            obj.blocks=block;
          
            for b=1:numel(obj.blocks)
                for t=1:obj.blocks(b).nr_trials
                    
                    obj.blocks(b).trial_types(t)=sampleDiscreteDistributions(obj.blocks(b).p_trial_type,1);
                    
                    obj.blocks(b).stimuli(t,:)= obj.trial_types{obj.blocks(b).trial_types(t)};
                                        
                    stims = obj.blocks(b).stimuli(t,:);
                    obj.blocks(b).events(t,1).stimulus=stims(1);
                    obj.blocks(b).events(t,1).duration=2.5;
                    obj.blocks(b).events(t,1).type='context';
                    obj.blocks(b).events(t,1).action_taken=false;
                    obj.blocks(b).events(t,1).action=NaN;
                    obj.blocks(b).events(t,1).action_evaluated=false;

                    obj.blocks(b).events(t,2).stimulus={''};
                    obj.blocks(b).events(t,2).duration=5;
                    obj.blocks(b).events(t,2).type='break';
                    obj.blocks(b).events(t,2).action_taken=false;
                    obj.blocks(b).events(t,2).action=NaN;
                    obj.blocks(b).events(t,2).action_evaluated=false;
                    
                    obj.blocks(b).events(t,3).stimulus=stims(2);
                    obj.blocks(b).events(t,3).duration=2;                    
                    obj.blocks(b).events(t,3).type='probe';
                    obj.blocks(b).events(t,3).action_taken=false;
                    obj.blocks(b).events(t,3).action=NaN;
                    obj.blocks(b).events(t,3).action_evaluated=false;
                    
                end
            end

        end
        
        function experiment = randomize(experiment)
            experiment = AXCPTExperiment();
        end
        
        function is_correct = isCorrect(experiment,response,trial)
            
        switch trial.type
            case 1 %AX
                is_correct = response==1;
                
            case 2 %AY
                is_correct = response==0;
            case 3 %BX
                is_correct = response==0;
            case 4 %BY
                is_correct = response==0;
        end
        
        end
        
        function [results,avg_results,agent]=simulateExperiment(experiment,agent,nr_simulations,nr_subjects)
            
            switch nargin
                case 2
                    nr_simulations = 1;
                    nr_subjects = 1;
                case 3
                    nr_subjects = 1;
            end                    
            
            results=struct('trials',[],'responses',[],'rewards',[],'reward',[],'cognitive_history',[]);            
            
            for sim=1:nr_simulations
                for sub=1:nr_subjects
                    
                    %reiniatialize the agent
                    agent=agent.newSubject();
                    %randomize the block order and trials
                    experiment = experiment.randomize();

                    
                    for b=1:experiment.nr_blocks
                        
                        for t=1:experiment.blocks(b).nr_trials
                           
                           events = experiment.blocks(b).events(t,:); 
                           [agent,w,x,y,z,za,zb,zc]= ...
                               experiment.simulateTrial(events,agent); 
                           
                           results.actions(sub,sim,b,t,:)=w;
                           results.rewards(sub,sim,b,t,:)=x;
                           results.RT(sub,sim,b,t)=y;
                           results.block_type(sub,sim,b,t) = experiment.block_order(b);
                           results.trial_type(sub,sim,b,t) = experiment.blocks(b).trial_types(t);
                           results.cognitive_history{sub,sim,b,t}=z;
                           
                           
                           results.response(sub,sim,b,t)=za;
                           results.correct(sub,sim,b,t)=zb;
                           results.response_modes{sub,sim,b,t}=zc;
                           results.goalPursuit(sub,sim,b,t)=sum(strcmp(zc,'goalPursuit'));
                           
                           results.reward(sub,sim,b,t)=sum(results.rewards(sub,sim,b,t,:));
                           
                           results.trial_type(b,t)=experiment.blocks(b).trial_types(t);
                        end
                        
                        %results(b).avg_reward_rate = mean(results(b).reward(:)./results(b).RT(:));
                        %results(b).sem_reward_rate = sem(results(b).reward(:)./results(b).RT(:));                        
                    end
                end
            end
            
            %average of the results by block order, block, trial type, and trial
            all_trial_types = unique([experiment.blocks(:).trial_types]);
            nr_trial_types = numel(all_trial_types);
            for block_type=1:2
                for t=1:nr_trial_types
                    condition = and(results.block_type(:)==block_type,...
                        results.trial_type(:)==all_trial_types(t));
                    
                    avg_results.reward(block_type,t) = ...
                        mean(results.reward(condition));
                    
                    avg_results.correct(block_type,t) = ...
                        mean(results.correct(condition));
                    
                    avg_results.RT(block_type,t) = ...
                        nanmean(results.RT(condition));
                    
                    avg_results.goalPursuits(block_type,t) = ...
                        nanmean(results.goalPursuit(condition));
                end
            end
            
            avg_results.rewards=squeeze(mean(mean(results.reward,1),2));
            avg_results.RTs=squeeze(nanmean(nanmean(results.RT,1),2));
            avg_results.correctness_values=squeeze(mean(mean(results.correct,1),2));
            avg_results.goalPursuit=squeeze(nanmean(nanmean(results.goalPursuit,1),2));
            
        end
        
        function [agent,actions,rewards,RT,cognitive_history,response,correct,response_modes] = ...
                simulateTrial(experiment,events,agent)
            
            nr_events = numel(events);
            
            actions = [];
            rewards = [];
            first_actions = nan(3,1);
            for i=1:nr_events
                event = events(i);
                event.new_event = true;
                nr_cycles = ceil(event.duration*agent.cycles_per_second);
                
                modes_by_event{i}=cell(nr_cycles,1);
                clear event_actions
                for k=1:nr_cycles
                    [agent,event_actions(k,1)] = agent.nextCycle(event);
                    modes_by_event{i}{k} = agent.mode;
                    
                    [reward,event] = agent.monitorPerformance(event_actions(end),event);
                    rewards=[rewards,reward];
                    event.new_event = false;
                end
                actions=[actions;event_actions];
                
                %if an action was taken, then determine the RT and what the action was
                if any(not(isnan(event_actions))) 
                    t_first_action = find(~isnan(event_actions),1,'first');
                    RTs(i)=1/agent.cycles_per_second*t_first_action;
                    %we assume that the first action is registered as the
                    %participant's response
                    first_actions(i) = event_actions(t_first_action);
                else
                    %when no action was taken, then there is no reaction
                    %time.
                    RTs(i)= NaN; 
                end
            end
            
            
            response_modes=modes_by_event{3};
            RT = RTs(end);
            %response given in the probe phase of the trial
            response = first_actions(end);
            
            
            correct = experiment.isCorrect(response,events);
            
            %modes_by_event{1}
            %modes_by_event{2}
            %modes_by_event{3}
            
            cognitive_history = agent.cognitive_history;
            
            agent=agent.learn(sum(rewards)); %
        end

    end
end

