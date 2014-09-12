clear

subjectInitial = {'n','j','m'};
difficultyName = {'L', 'M', 'S'};

tx = [ -1.3944   -1.3334   -1.2142   -1.0419   -0.8241   -0.5703   -0.2915 ... 
         0    0.2915    0.5703    0.8241    1.0419    1.2142    1.3334  1.3944];

ty = [ 3.3650    3.9448    2.8105    4.4497    2.3773    4.7924    2.140 ...
    4.9136    2.1402    4.7924    2.3773    4.4497    2.8105    3.9448 3.3650];

targScales = [0.1353,0.1353,0.1353, 0.0902,0.0902,0.0902, 0.0451,0.0451,0.0451].*100;

% create my own colormap
custcmap = buildcmap('wbr');

figure(1), clf
colormap(custcmap)

subpnum = 1;

for mode = 1:3
    for di = 1:3
        
        fname = [cd '\easyaccesspointclickdata\' subjectInitial{mode} '_' difficultyName{di}];
        load(fname)
        subplot(3,3,subpnum)
        heatmap(gdmat);
        title(['All Subs. ' subjectInitial{mode} ':' difficultyName{di}])
        ylim([0 40]) 
        
        drawnow
        
        
        subpnum = subpnum + 1;
        
        
    end
end


% %draw the target locations over that
for subpnum = 1:9
    
    subplot(3,3,subpnum)
    hold on
    plot(tx.*9.5+21, (ty-4)*8 + 18.5, 'ko', 'LineWidth', 3, 'MarkerSize', targScales(subpnum))

end


for subpnum = 1:9
    subplot(3,3,subpnum)
    ylim([-5 40])
    axis equal
end

