function out = AllArmiesAlive(armies)
    for ii = 1:size(armies,3)
        if (sum(sum(armies(:,:,ii))) == 0)
            out = false;
            return;
        end
    end
    out = true;
end