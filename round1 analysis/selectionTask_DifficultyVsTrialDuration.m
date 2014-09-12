% bar graph showing selection task and difficulty vs trial duration

subjectIDs = {'s3', 's4', 's5', 's7'};
subjectInitial = {'n','j','m'};


for subs = 1:4
    
    subject = subjectIDs{subs};
    subIn = subjectInitial{1};
    
    % logfile
    log = xlsread([cd '\' subject '\' 'selection_log_' subject '_' subIn '.csv']);
    
    % detailed data
    data = xlsread([cd '\' subject '\' 'selection_detail_log_' subject '_' subIn '.csv']);
    
    %% look at elapsed time as a function of difficulty
    
    % difficulty based on target size_index (col 5)

    diffID = 1;
    
    for diffi = 2:-1:0
        
        trlID = find(log(:,5) == diffi & log(:,13) == 1); % log file rows of successes
        elapsedTimes = log(trlID, 12) ./ 1000; % in seconds
        
        % special condition - wand flyoff
        if strcmp(subject, 's5')
            idxFlyOff = find(elapsedTimes > 8);
            elapsedTimes(idxFlyOff) = [];
        end
        
        meanET(subs, diffID) = nanmean(elapsedTimes);
        stdET(subs, diffID) = nanstd(elapsedTimes);
        
        diffID = diffID + 1;
        
    end %diff
    
end % subs

barweb(meanET, stdET, 1, subjectIDs);
ylabel('Duration of Trials (sec)')