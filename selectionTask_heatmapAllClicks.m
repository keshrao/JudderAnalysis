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
for subs = 1:20
    
    if subs == 13 || subs == 19
        continue
    end
    
    
    % --- modes
    for mode = 1:3;
        
        subject = subjectIDs{subs};
        subIn = subjectInitial{mode};
        
        isLoad = true;
        
        if isLoad
            % logfile
            % log = xlsread([cd '\KeshRawData\' subject '\' 'selection_log_' subject '_' subIn '.csv']);
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
        for di = 1:3;
            
            
            % separate out the trials
            diffi = difficulty(di);
            
            if diffi == 2
                thisdata = data1;
            elseif diffi == 1
                thisdata = data2;
            elseif diffi == 0
                thisdata = data3;
            end
            
            
            % button status = 23
            idxDepress = thisdata(:,23) == 1;
            xPosDepress = thisdata(idxDepress, 19);
            yPosDepress = thisdata(idxDepress, 20);
            

            plot(xPosDepress, yPosDepress, '.'); axis([-2 2 2 6])
            
        end % difficulti
        
        
        
    end %  mode
    
    
    
end % subs