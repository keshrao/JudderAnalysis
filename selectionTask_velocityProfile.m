% plot the velocity profile of the hand trajectory
% separated by normal (L,M,S), judder (L,M,S), masking (L,M,S)
% also shown is the mean end time for each condition

subjectIDs = {'s1', 's2', 's3','s4','s5','s6', 's7', 's8','s9','s10', ...
                's11', 's12', 's13', 's14','s15','s16', 's17', 's18', 's19', 's20'};
            
subjectInitial = {'n','j','m'};


% current setup goes nL, nM, nS; jL, jM, jS;

maxspeedsMean = nan(3,3,length(subjectIDs)); % < [nL nM nS; jL, jM....];
maxspeedsStd = nan(3,3,length(subjectIDs)); % modes are rows. diffi are cols. 3rd index is subjects


for subs = 1:length(subjectIDs)
    
    if subs == 13 || subs == 19
        continue
    end
    
    %figure(1), clf
    
    for mode = 1:3  %normal, masking, judder

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

        %%

        %separate the data into three parts (easy times, med times, hard times)

        indSplit = find(abs(diff(data(:,1))) > 1000);
        data1 = data(1:indSplit(1),:);
        data2 = data(indSplit(1)+1:indSplit(2),:);
        data3 = data(indSplit(2)+1:end,:);

        colors = {'r', 'g', 'b'};
        htot = [];
        
        indDiffi = [2,1,0];

        for di = 1:3
            diffi = indDiffi(di); 

            if diffi == 2
                thisdata = data1;
            elseif diffi == 1
                thisdata = data2;
            elseif diffi == 0
                thisdata = data3;
            end

            trlID = find(log(:,5) == diffi & log(:,13) == 1); % log file rows of successes
            trlTS = log(trlID, 1); % time stamps of trial end


            idxEnd = nan(length(trlTS),1);

            for trli = 1:length(trlTS)
                if ~isempty(find(floor(thisdata(:,1)) == trlTS(trli)))
                    idxEnd(trli) = find(floor(thisdata(:,1)) == trlTS(trli));
                else
                    idxEnd(trli) = idxEnd(trli-1);
                    disp('bad trial')
                end
                   
            end


            %%

            timeprof = nan(length(trlTS), 500); % store time stamps as well 
            velprof =  nan(length(trlTS), 500); % sufficiently many columns

            starti = 1;
            for trli = 1:length(trlTS)

                if mode == 1
                    scaling = 1/55;
                else
                    scaling = 1/11;
                end
                
                % velocity calculated using distance from target
                %thisprof = (diff(thisdata(starti:idxEnd(trli),22))/scaling).^2;
                
                % use the x/y position intersection and collect the speed
                thisxpath = thisdata(starti:idxEnd(trli),19);
                thisypath = thisdata(starti:idxEnd(trli),20);
                
                thisxvel = diff(thisxpath)./scaling; thisyvel = diff(thisypath)./scaling;
                thisspeed = sqrt(thisxvel.^2 + thisyvel.^2);

                
                % store velocity profile and corresponding time stamps
                velprof(trli,1:length(thisspeed)) = thisspeed;
                timeprof(trli, 1:length(thisspeed)) = thisdata(starti:idxEnd(trli)-1,1);

                starti = starti + (idxEnd(trli)-starti) + 1;
            end

            % find the time each trial took in ms
            trldurs = nan(length(trlTS),1);
            
            % also compute the max values for each condition
            thismaxval = nan(length(trlTS),1);
            
            for trli = 1:length(trlTS)
                numvalid = find(~isnan(timeprof(trli,:)));
                if ~isempty(numvalid)
                    trldurs(trli) = timeprof(trli,numvalid(end)) - timeprof(trli, numvalid(1));
                else
                    trldurs(trli) = nan;
                end
                
                thismaxval(trli) = nanmax(velprof(trli,:));
            end
            
            plot(thismaxval,'b'); hold on
            
            % some sanity checks
            thismaxval(thismaxval > 60) = [];
            
            plot(thismaxval,'r')
            title(subjectIDs{subs})
            drawnow
            
            %store the mean and stds of the max values
            maxspeedsMean(mode, di, subs) = nanmean(thismaxval);
            maxspeedsStd(mode, di, subs) = nanstd(thismaxval);


            meanprof = nanmean(velprof,1);
            stdprof = nanstd(velprof,1);

            % time between successive time points
            % either 55Hz or 11Hz
            numIdx1Sec = round(1/scaling);

%             % plotting
%             subplot(3,1,mode), hold all
%             h = plot(linspace(0,1,numIdx1Sec),meanprof(1:numIdx1Sec), colors{diffi+1}, 'LineWidth', 3);
%             htot = [htot, h];
%             
%             % show when the trial ended
%             plot([nanmean(trldurs) nanmean(trldurs)]./1000, [0 max(meanprof)], colors{diffi+1}, 'LineWidth', 2)
%             
%             title(['Sujbect: ' subject ', Mode: ' subIn])
%             ylim([0 15])
%             xlim([0 2.5])
%             
%             
%             if mode == 1 && diffi == 0
%                 legend(htot, {'Easy','Medium','Hard'})
%             end
%             drawnow
            
            % just to view, plot all the overlaid individual trials
%             figure(subs+1)
%             subplot(3,1,mode), hold on
%             for trli = 1:length(trlTS)
%                 numvalid = find(~isnan(timeprof(trli,:)), 1, 'last' );
%                 plot(linspace(0,trldurs(trli),numvalid), velprof(trli, 1:numvalid), colors{diffi+1},'LineWidth', 0.5)
%             end
%             drawnow
        end

    
    end %mode
    
    
    
    %saveas(gcf, subject, 'pdf')
    
end %sub

%% compress data from subjects
% keyboard
% 
% for subs = 1:length(subjectIDs)
%     if subs == 13 || subs == 19
%         continue
%     end
% 
%     figure(subs)
%     barweb(maxspeedsMean(:,:,subs), maxspeedsStd(:,:,subs), 1, {'Normal', 'Judder', 'Masking'})
%     title(['Subject: ' (subjectIDs{subs})])
%     drawnow
%     saveas(gcf, num2str(subs), 'pdf')
% end


allsubsMean = nanmean(maxspeedsMean,3);
allsubsStd = nanstd(maxspeedsStd(:,:,1:4),1, 3);

figure(25)
barweb(allsubsMean, allsubsStd, 1, {'Normal','Judder','Masking'});
title(['All Subs; Max Speed Values'])



