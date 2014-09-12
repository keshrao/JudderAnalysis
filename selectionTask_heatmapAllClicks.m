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

tx = [ -1.3944   -1.3334   -1.2142   -1.0419   -0.8241   -0.5703   -0.2915 ... 
         0    0.2915    0.5703    0.8241    1.0419    1.2142    1.3334  1.3944];

ty = [ 3.3650    3.9448    2.8105    4.4497    2.3773    4.7924    2.140 ...
    4.9136    2.1402    4.7924    2.3773    4.4497    2.8105    3.9448 3.3650];

targScales = [0.1353,0.1353,0.1353, 0.0902,0.0902,0.0902, 0.0451,0.0451,0.0451].*100;

% create my own colormap
custcmap = buildcmap('wbr');


figure(1), clf
subpnum = 1;

colormap(custcmap);


div = 60;
xvec = linspace(-2,2,div);
yvec = linspace(2,7,div);
[xgd, ygd] = meshgrid(xvec, yvec);



% --- modes
for mode = 1:3;
    
    
    
    % --- difficulty setting
    for di = 1:3;
        
        
        % one matrix per condition
        gdmat = zeros(div);
        
        % --- subject numbers
        for subs = 1:20
            
            if subs == 13 || subs == 19
                continue
            end
            
            subject = subjectIDs{subs};
            subIn = subjectInitial{mode};
            
            isLoad = true;
            
            if isLoad
                % logfile
                % log = xlsread([cd '\KeshRawData\' subject '\' 'selection_log_' subject '_' subIn '.csv']);
                % detailed data
                tic
                data = xlsread([cd '\KeshRawData\' subject '\' 'selection_detail_log_' subject '_' subIn '.csv']);
                toc
            else
                disp('File Not Loaded')
            end
            
            
            %% separate the data into three parts (easy times, med times, hard times)
            
            indSplit = find(abs(diff(data(:,1))) > 1000);
            data1 = data(1:indSplit(1),:);
            data2 = data(indSplit(1)+1:indSplit(2),:);
            data3 = data(indSplit(2)+1:end,:);
            
            
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
            xPos = thisdata(idxDepress, 19);
            yPos = thisdata(idxDepress, 20);
            
            
            for thisI = 1:sum(idxDepress)
                
                col = find(xvec > xPos(thisI), 1, 'first');
                row = find(yvec > yPos(thisI), 1, 'first');
                
                gdmat(row,col) = gdmat(row,col) + 1;
                
            end
            

            
        end % subs
        
        
        subplot(3,3,subpnum)
        colormap(custcmap)
        heatmap(gdmat);
        title(['All Subs. ' subjectInitial{mode} ':' difficultyName{di}])
        drawnow
        pause(0.1)
        
        subpnum = subpnum + 1;
        
        
        save([subjectInitial{mode} '_' difficultyName{di}], 'gdmat')
    end %  difficulty
    
    
    
end % mode