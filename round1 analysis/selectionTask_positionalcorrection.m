% % plot the velocity profile of the hand trajectory
%
subjectIDs = {'s3', 's4', 's7','s10','s11'};
subjectInitial = {'n','j','m'};
difficulty = [2,1,0];
difficultyName = {'L', 'M', 'S'};

% --- subject numbers
subs = 1;

hf = figure(subs); clf
subpnum = 1;

% collect all the average traces
vecRmeanX = nan(9, 400); 
vecRmeanY = nan(9, 400); 
coltill = nan(9,1);

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
    
    
    % --- difficulty setting from 1:3
    for di = 1:3;
        
        %% separate out the trials
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
        ty = ty-mean(ty);
        
        thisVecMeanX = nan(length(idxEnd),400);
        thisVecMeanY = nan(length(idxEnd),400);
        
        subplot(3,3,subpnum), hold on
        
        prevLoc = 1;
        for trli = 1:length(idxEnd)
            
            %if idxEnd(trli) - prevLoc > mean(diff(idxEnd))+2*std(diff(idxEnd))  % wand flyoff
            %   disp(['Skipped Trial: ' num2str(idxEnd(trli) - prevLoc)])
            %   continue
            %end
            
            xRpre1 = thisdata(prevLoc:idxEnd(trli),19) - thisdata(prevLoc,19);
            yRpre1 = thisdata(prevLoc:idxEnd(trli),20) - thisdata(prevLoc,20);
            
            %tdir = atan2d(ty(trli), tx(trli)); % << using the target location to compute the dir
            tdir = atan2d(yRpre1(end), xRpre1(end)); % << i like this better. flatter
            
            vecR = [cosd(-tdir) -sind(-tdir); sind(-tdir) cosd(-tdir)]*[xRpre1, yRpre1]';
             
            thisVecMeanX(trli,1:length(vecR)) = vecR(1,:);
            thisVecMeanY(trli,1:length(vecR)) = vecR(2,:);
            
            plot(vecR(1,:), vecR(2,:), 'b')
            title([subject ': ' subIn ': ' num2str(diffi)])
            %plot(xRpre1, yRpre1, '--b', tx(trli)*2, ty(trli)*2, 'ro', vecR(1,:), vecR(2,:), 'b')
            axis([-1 5 -3 3])
            drawnow
            
            
            
            prevLoc = idxEnd(trli) + 1;
        end
        
        % find when there are at least 4 trials this long
        col = 1;
        while sum(~isnan(thisVecMeanX(:, col))) > round(size(thisVecMeanX,1)/2)
            col = col + 1;
        end
        
        vecRmeanX(subpnum, 1:col) = nanmean(thisVecMeanX(:,1:col),1);
        vecRmeanY(subpnum, 1:col) = nanmean(thisVecMeanY(:,1:col),1);
        coltill(subpnum) = col;
        
        plot(vecRmeanX(subpnum,1:col), vecRmeanY(subpnum,1:col), 'r', 'LineWidth', 2)
        drawnow
       subpnum = subpnum + 1; 
    end %difficulty
    
end %mode - n,m,j



%% just looking at averages

% it appears as though it's always going up and to the right because the
% target is always moving further around in a circle and not just moving
% diametrially opposite.

% now plot the three modes in one and separate by difficulty
% the data is [nL nM nS; jL jM jS; mL mM mS]

figure(2), clf

colors = {'b','g','r'};

subpnum = 1;
for diffI = 1:3;

    subplot(3,2,subpnum)
    plot(vecRmeanX(diffI:3:9,:)', vecRmeanY(diffI:3:9,:)')
    axis([-0.5 5 -0.5 0.5])
    
    title([subject ': ' difficultyName{diffI}])
    
    subpnum = subpnum + 1;
    
    
    subplot(3,2,subpnum), hold all

    colorsI = 1;
    for thisI = diffI:3:9
        
        thisCT = coltill(thisI);
        plot(vecRmeanX(thisI, thisCT-round(thisCT/2):thisCT),vecRmeanY(thisI, thisCT-round(thisCT/2):thisCT), colors{colorsI})
        plot(vecRmeanX(thisI, thisCT), vecRmeanY(thisI, thisCT), [colors{colorsI} 's'])
        xlim([2 3])
        ylim([-0.5 0.5])
        colorsI = colorsI + 1;
    end
    
    
    subpnum = subpnum + 1;
end




