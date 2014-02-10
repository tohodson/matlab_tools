function output = geomorphons( dem , res, look, flatness )

lookup = [ 1 1 1 2 2 3 3 3 4; ...
           1 1 2 2 2 3 3 3 0; ...
           1 5 6 6 7 7 3 0 0; ...
           5 5 6 6 6 7 0 0 0; ...
           5 5 8 6 6 0 0 0 0; ...
           9 9 8 8 0 0 0 0 0; ...
           9 9 9 0 0 0 0 0 0; ...
           9 9 0 0 0 0 0 0 0; ...
          10 0 0 0 0 0 0 0 0 ];
      
bsize = 2*look+1; %block size

dist(:,1) = abs(-look:1:look) .* res;
dist(:,2) = dist(:,1);
dist(:,3) = hypot(1,1).*dist(:,1);
dist(:,4) = dist(:,3);
dist( dist > look.*res) = NaN;
% pad dem with nans
dem = padarray(dem,[look look],nan);

function geomorphon = geomorphFilter(block)

  elev(:,1) = block(:,look+1);
  elev(:,2) = block(look+1,:);
  elev(:,3) = diag(block);
  elev(:,4) = diag(fliplr(block));
  home = elev(look+1,1); %elev at center of block

  altitude(1:4) = max(atand((elev(1:look,:) - home)./ dist(1:look,:)));
  altitude(5:8) = max(atand((elev(look+1:end,:) - home)./ ...
                        dist(look+1:end,:)) ,[],1);

  %openval = mean(open);
  geomorphon = lookup(sum(altitude < -flatness)+1 ,...
                        sum(altitude > flatness)+1);
end

padded = nlfilter( dem, [bsize bsize] ,@geomorphFilter);

% remove padding
output = padded(1+look:end-look(1),1+look:end-look);

end