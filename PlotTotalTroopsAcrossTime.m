function out = PlotTotalTroopsAcrossTime(troopMatrix, timeInterval)
    figure;
    hold on;
    totalTroopsX = sum(troopMatrix,1);
    for ii = 1:size(troopMatrix,2)
        a = totalTroopsX(:,ii,:);
        plot(timeInterval,reshape(a,1,size(a,3),1));
    end
end