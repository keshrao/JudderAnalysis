% create a virtual line between the starting point of the wand in a trial
% and the target location. That line is the optimal trajectory of the wand
% during that trial. Compare the actual versus the optimal and determine if
% there are any differences between the lines.

subjectIDs = {'s3', 's4', 's7','s10','s11'};
subjectInitial = {'n','j','m'};
difficulty = [2,1,0];
difficultyName = {'L', 'M', 'S'};
modeColor = {'b','g','r'};

close all

% --- subject numbers
subs = 3;


% --- modes
for mode = 1:3;
    
    subject = subjectIDs{subs};
    subIn = subjectInitial{mode};
    
    isLoad = true;
    
    if isLoad
        % logfile
        log = xlsread([cd '\' subject '\' 'selection_log_' subject '_' subIn '.csv']);
        % detailed data
        data = xlsread([cd '\' subject '\' 'selection_detail_log_' subject '_' subIn '.csv']);
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
        %ty = ty-mean(ty);
        
        % plot(tx, ty, 'bo') < [-1.5 1.5, -1.5 1.5]
        
        interval = nanmean(diff(thisdata(:,1)));
        
        
        %% iterate through each trial and find the optimal trajectory
        figure(mode)
        
        tDir = nan(length(idxEnd),1);
        pathDir = nan(length(idxEnd), 250);
        
        prevLoc = 1;
        for trli = 1:length(idxEnd)   % first one is always bad
            
            
            %if idxEnd(trli) - prevLoc > mean(diff(idxEnd))+2*std(diff(idxEnd))  % wand flyoff
            %   disp(['Skipped Trial: ' num2str(idxEnd(trli) - prevLoc)])
            %   continue
            %end
            
            xTraj = thisdata(prevLoc:idxEnd(trli),19);
            yTraj = thisdata(prevLoc:idxEnd(trli),20);
            
            figure(5)
            for i = 1:length(xTraj)
                plot(xTraj(i), yTraj(i), '.')
                
                axis([-2 2 -1 6])
                drawnow
            end
            
            % the directions go: 0deg = right. Counter clockwise till 359deg
            tDir(trli) = atan2d(ty(trli)-yTraj(1), tx(trli)-xTraj(1));
            
            % stupid buggy atan2d
            for i = 1:length(xTraj)-1
                % compute the difference in positions to get the heading
                thisPathDir(trli,i) = atan2d(yTraj(i+1)-yTraj(i), xTraj(i+1)-xTraj(i));
            end
            
            
            pathDir(trli,1:length(xTraj)-1) = thisPathDir(trli,1:length(xTraj)-1) - tDir(trli);
            
            tvec = linspace(0,length(xTraj)*interval,length(xTraj)-1);
            
            if max(tvec) > 1500
                prevLoc = idxEnd(trli) + 1;
                continue
            end
            
%             subplot(2,2,1), hold on
%             plot(xTraj, yTraj, '--b', tx(trli), ty(trli), 'ro')
%             title([subject ': ' subIn ': ' num2str(diffi)])
%             axis([-2 2 2 5.5])
%             
%             subplot(2,2,3:4), hold on
%             plot(tvec, pathDir(trli, 1:length(xTraj)-1) , 'b')
%             ylim([-360 360])
            
            
            
            drawnow
            
            
            prevLoc = idxEnd(trli) + 1;
        end
        
        
        %% compute the mean difference in direction
        
        col = 1;
        while sum(~isnan(pathDir(:, col))) > round(size(pathDir,1)/2)
            col = col + 1;
        end
        
        
        meanPathDir = abs(nanmean(pathDir(:,1:col),1));
        
        plot(linspace(0,col*interval,col),meanPathDir, 'r', 'LineWidth', 2)
        
        figure(4), subplot(3,1,di), hold on
        plot(linspace(0,col*interval,col),meanPathDir, modeColor{mode}, 'LineWidth', 2)
        xlabel('Time (ms)')
        ylim([-5 90])
        
        legend('normal','judder','masking')
        title([subject ': ' subIn ': ' num2str(diffi)])
        
    end % difficulti
    
    

end %  mode



