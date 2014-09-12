subjectIDs = {'s1','s2','s3','s4','s5','s7','s8','s9','s10', ...
                's11','s12','s14','s15','s16','s17','s18','s20'};
subjectInitial = {'n','j','m'};
difficulty = {'L', 'M', 'S'};


% kesh: delete the number at the top of the text file indicating the
% number of indexs in the file
path = dlmread('path.txt');
xpath = path(:,1);
ypath = path(:,2);

% construct a simple heatmap
xmin = min(xpath) - 5;
xmax = max(xpath) + 5;
ymin = min(ypath) - 5;
ymax = max(ypath) + 5;

divs = 100;
xrng = linspace(xmin, xmax, divs);
yrng = linspace(ymin, ymax, divs);
hmapPath = zeros(divs);
hmap = zeros(divs);

[xgd, ygd] = meshgrid(xrng, yrng);

% check each voxel and see if there is a path in that region
for row = 2:divs
    for col = 2:divs
        
        idxThis = find(xpath > xgd(row-1,col-1) & xpath < xgd(row,col) & ypath > ygd(row-1,col-1) & ypath < ygd(row,col));
        if ~isempty(idxThis)
            hmapPath(row,col) = 1;
        end
        
        
    end
end


% to put into for loop
mode = 3;

% to put into for loop
for subs = 1:length(subjectIDs)
    
    
    for diffi = 1:3;
        
        subject = subjectIDs{subs};
        subIn = subjectInitial{mode};
        
        isLoad = true;
        
        if isLoad
            
            % detailed data
            [alldata, txt, ~] = xlsread(['..\RawData\' subject '\' 'navigation_detail_' subject '_' subIn '.csv']);
            
            if size(alldata,2) == 21 % error bc of way matlab interprets 0,1,2 vs L,M,S
                alldata(:,1:2) = [];
                fprintf('Del Sub: %i \n', subs)
            end
        else
            disp('File Not Loaded')
        end
        
        %sort the easy data
        idxMode = strcmp(txt(:,2),difficulty{diffi});
        %note that the txt data has a header at the top so delete the first entry
        idxMode(1) = [];
        
        
        % collisions can be left (1) or right (2)
        data = alldata(idxMode,:);
        isCollide = find(data(:,10) > 0);
        
        if isempty(isCollide)
            fprintf('No Collisions: %i \n', subs)
            break
        end
        
        % store the x/y positions of all the collisions that are happening
        for iC = 1:length(isCollide)
            xCollideI = data(isCollide(iC), 2);
            thisR = find(xgd(1,:) > xCollideI, 1, 'first');
            
            yCollideI = data(isCollide(iC), 3);
            thisC = find(ygd(:,1) > yCollideI, 1, 'first');
            
            hmap(thisC, thisR) = hmap(thisC, thisR) + 1; % yes this is flipped
        end
        
    end % diffi
end


%%

red = cat(3, ones(size(hmap)), zeros(size(hmap)), zeros(size(hmap)));
green = cat(3, zeros(size(hmap)), ones(size(hmap)), zeros(size(hmap)));

hpath = flipud(hmapPath);
hcollimap = flipud(hmap./max(max(hmap)));

forPlotMap = (cat(3, hcollimap, zeros(size(hpath)), hpath./8));

heatmap(forPlotMap)
title(['Mode: ' subjectInitial{mode}])
