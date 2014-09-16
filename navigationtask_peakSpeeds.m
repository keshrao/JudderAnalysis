clc; clear;


subjectIDs = {'s1', 's2', 's3','s4','s5','s6', 's7', 's8','s9','s10', ...
                's11', 's12', 's13', 's14','s15','s16', 's17', 's18', 's19', 's20'};
subjectInitial = {'n','j','m'};
difficulty = {'L', 'M', 'S'};

tnames = {'nL', 'nM', 'nS', 'jL', 'jM', 'jS', 'mL', 'mM', 'mS'};

avgSpeeds = nan(3,3,length(subjectIDs)); % < [nL nM nS; jL, jM....];
% row = mode; col = diffi; depth = subs 

figure(1)

% to put into for loop
for subs = 1:20
    
    if subs == 13 || subs == 19
        continue
    end
    
     clf
    subpnum = 1;
    
    % to put into for loop
    for mode = 1:3;
        
        for diffi = 1:3;
            
            subject = subjectIDs{subs};
            subIn = subjectInitial{mode};
            
            isLoad = true;
            
            if isLoad
                % detailed data
                [alldata, txt, ~] = xlsread([cd '\KeshRawData\' subject '\' 'navigation_detail_' subject '_' subIn '.csv']);
                
                if size(alldata,2) == 21 % error bc of way matlab interprets 0,1,2 vs L,M,S
                    keyboard
                end
            else
                disp('File Not Loaded')
            end
            
            %sort the easy data
            idxMode = strcmp(txt(:,2),difficulty{diffi});
            %note that the txt data has a header at the top so delete the first entry
            idxMode(1) = [];
            
            data = alldata(idxMode,:);
            isCollide = data(:,10) == 1 | data(:,10) == 2;
            
            % frame rate;
            interval = mean(diff(data(:,1)))/1000; % 55Hz or 11Hz. Ie. 18ms or 90ms.
            
            xvel = movingmean(data(:,4)./interval,10);
            yvel = movingmean(data(:,5)./interval,10);
            
            
            spd = sqrt(xvel(~isCollide).^2 + yvel(~isCollide).^2);
            
            oldspd = sqrt( (data(~isCollide,4)./interval).^2 + (data(~isCollide,5)./interval).^2);
            
            % take out any jumps in speed that happen during collisions
            idxJumps = find(abs(diff(spd)) > 0.2);
            spd(idxJumps) = nan;
            
            
%             subplot(3,3,subpnum)
%                 plot(oldspd, 'r'); hold on;
%                 plot(spd,'b');
%                 title(tnames{subpnum})
%                 ylim([0 8])
%                 drawnow
%                 subpnum = subpnum + 1;
%                 
                
            avgSpeeds(mode, diffi, subs) = nanmean(spd);
                
            fprintf('Subject %i, Mode %s, Difficulty %s : MeanSpd \n', subs, subIn, difficulty{diffi})
        end % diffi
        
    end % mode
    
end % subs


%% Go through and plot out the bar graphs for all subjects and then average them all

for subs = 1:20
    
    if subs == 13 || subs == 19
        continue
    end

    figure(1), clf
    barweb(avgSpeeds(:,:,subs),zeros(3), 1, {'N', 'J', 'M'})
    title(['Subject ' num2str(subs)])
    legend('L','M','S')
    ylim([0 8])
    drawnow
%    saveas(gcf,num2str(subs), 'pdf')
end

figure(2)
barweb(nanmean(avgSpeeds,3), nanstd(avgSpeeds,1,3), 1, {'N', 'J', 'M'})
ylim([0 8])
title('All Subjects: Mean Speed in Navigation')
legend('L','M','S')
