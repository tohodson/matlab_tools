function output = openness( dem , res, look )

%define the block size from the look paramater
bsize = 2*look+1; %block size

%create a distance matrix 
dist(:,1) = abs(-look:1:look) .* res;
dist(:,2) = dist(:,1);
dist(:,3) = hypot(1,1).*dist(:,1);
dist(:,4) = dist(:,3);
dist( dist > look.*res) = NaN;

dem = padarray(dem,[look look],nan); % pad dem with nans

%openval inherits dist 
function openval = openFilter(block)
    %nested function used in nlfilter
    
    elev(:,1) = block(:,look+1);
    elev(:,2) = block(look+1,:);
    elev(:,3) = diag(block);
    elev(:,4) = diag(fliplr(block));
    home = elev(look+1,1); %elev at center of block
    
    %for each direction,
    %openness = 90 - max(altitude)
    open(1:4) = 90 - max(atand((elev(1:look,:) - home) ./ dist(1:look,:)));
    open(5:8) = 90 - max(atand((elev(look+1:end,:) - home) ./ ... 
                    dist(look+1:end,:)) ,[] , 1);

    openval = mean(open);

end

pad_out = nlfilter( dem, [bsize bsize] ,@openFilter);

%strip padding to return raster with same size as dem
output = pad_out(look+1:end-look,look+1:end-look);

end