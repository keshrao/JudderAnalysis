% create a virtual line between the starting point of the wand in a trial
% and the target location. That line is the optimal trajectory of the wand
% during that trial. Compare the actual versus the optimal and determine if
% there are any differences between the lines.

subjectIDs = {'s1', 's2', 's3','s4','s5','s6', 's7', 's8','s9','s10', ...
    's11', 's12', 's13', 's14','s15','s16', 's17', 's18', 's19', 's20'};

subjectInitial = {'n','j','m'};

difficulty = [2,1,0];
difficultyName = {'L', 'M', 'S'};
modeColor = {'b','g','r'};

close all

% --- subject numbers
for subs = 1
   
    
    % --- modes
    for mode = 1:3;
        
        subject = subjectIDs{subs};
        subIn = subjectInitial{mode};
        
        isLoad = true;
        
        if isLoad
            % logfile
            log = xlsread([cd '\KeshRawData\' subject '\' 'selection_log_' subject '_' subIn '.csv']);
            % detailed data
            data = xlsread([cd '\KeshRawData\' subject '\' 'selection_detail_log_' subject '_' subIn '.csv']);
        else
            disp('File Not Loaded')
        end
        
        
        %% separate the data into three parts (easy times, med times, hard times)
        
        indSplit = find(abs(diff(data(:,1))) > 1000);
        data1 = data(1:indSplit(1),:);
        data2 = data(indSplit(1)+1:indSplit(2),:);
        data3 = data(indSplit(2)+1:end,:);
        
        
        % --- difficulty setting
        for di = 3
            
            % separate out the trials
            diffi = difficulty(di);
            
            if diffi == 2
                thisdata = data1;
            elseif diffi == 1
                thisdata = data2;
            elseif diffi == 0
                thisdata = data3;
            end
            
            
            % first find the ending time stamps of
            trlID = find(log(:,5) == diffi & log(:,13) == 1); % log file rows of successes
            trlTS = log(trlID, 1); % time stamps of trial end
            
            idxEnd = nan(length(trlTS),1);
            tx = nan(length(trlTS),1);
            ty = nan(length(trlTS),1);
            
            for trli = 1:length(trlTS)
                idxEnd(trli) = find(floor(thisdata(:,1)) == trlTS(trli));
                tx(trli) = thisdata(idxEnd(trli)-1, 14);
                ty(trli) = thisdata(idxEnd(trli)-1, 15);
                
            end
            
            interval = nanmean(diff(thisdata(:,1)));
            tsize = thisdata(1, 17); % target scale
            
            %% iterate through each trial and find the optimal trajectory
            
            figure(1), clf, hold on
            
            trlstoStore = 20;
            numFrames = idxEnd(trlstoStore);
                        
            prevLoc = 1;
            for trli = 1:trlstoStore %length(idxEnd)   % first one is always bad
                
                
                xTraj = thisdata(prevLoc:idxEnd(trli),19);
                yTraj = thisdata(prevLoc:idxEnd(trli),20);
                
                
                plot(tx(trli), ty(trli), 'ro', 'MarkerSize', tsize*100);
                
                for ti = 1:length(xTraj)
                    plot(xTraj(ti), yTraj(ti), '.') 
                    title(['Subject: ' subject ', Mode = ' subjectInitial{mode} ':' difficultyName{di}])
                    axis([-2 2 2 6])
                    drawnow
                    
                    filedir = 'C:\Users\Hrishikesh\Desktop\frames\';
                    saveas(gcf, [filedir 'Subject' subject 'Mode' subjectInitial{mode} difficultyName{di} '_' num2str(trli) '_' num2str(ti)], 'jpg')
                end
                
                
                
                prevLoc = idxEnd(trli) + 1;
            end

            
        end % difficulti
        
        
        
    end %  mode
    
    
    
end % subs