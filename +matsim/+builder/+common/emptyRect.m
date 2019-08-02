function varargout = emptyRect(grid,minw,minh)

    if isempty(grid)        
        return
    end

    [nRows,nColumns] = size(grid);
    cache = zeros(1,nColumns);
 
    bestArea = 0;
    if nargin == 3
        minArea = calcScore(minw,minh);
    else
        minArea = 0;
    end
    bestL = struct('x',0,'y',0);
    bestU = struct('x',-1,'y',-1);

    stack = struct('m0',{},'w0',{});
    for n = 1:nRows
        cache = updateCache(cache,grid,n);
        width = 0;
        for m = 1:nColumns
            if cache(m) > width
                stack(end+1) = struct('m0',m,'w0',width);
                width = cache(m);
            end
            if (cache(m) < width) 
                p = struct('m0',{},'w0',{});
                while true
                    if isempty(stack)
                        break;
                    end
                    p = stack(end);
                    stack(end) = [];
                    area = calcScore(width, m - p.m0);
                    if (area > bestArea) 
                        bestArea = area;
                        bestL = struct('x',p.m0,'y',n);
                        bestU = struct('x',m - 1,'y',n - width + 1);                        
                        if (bestArea>minArea)
                            [varargout{1:nargout}] = setReturnValue(bestL,bestU);
                            return
                        end
                    end
                    width = p.w0;
                    if cache(m) < width
                        break
                    end
                end
                width = cache(m);
                if width ~= 0
                    stack(end+1) = struct('m0',p.m0,'w0',p.w0);
                end
            end
        end
    end
    if (bestL.x < 0 || bestL.y < 0 || bestU.x < 0 || bestU.y < 0) 
        error('Error: no maximal rectangle can be found')
    end
    if bestArea >= minArea
        [varargout{1:nargout}] = setReturnValue(bestL,bestU);
    else
        [varargout{1:nargout}] = deal([]);
    end
end

function varargout = setReturnValue(bestL,bestU)
    if nargout == 1
        varargout{1} = struct;
        varargout{1}.left = bestL.x;
        varargout{1}.right = bestU.x;
        varargout{1}.top = bestL.y;
        varargout{1}.bottom = bestU.y;
    elseif nargout == 4
        varargout{1} = bestL.x;
        varargout{2} = bestU.x;
        varargout{3} = bestL.y;
        varargout{4} = bestU.y;
    elseif nargout ~= 0
        error('Invalid number of output args.')
    end
end

function score = calcScore(width,height)
    score = width*height;
end

function cache = updateCache(cache, grid, n) 
    [~,nColumns] = size(grid);
    for m = 1:nColumns
        if (grid(n,m) == false)
            cache(m)=cache(m)+1;
        else
            cache(m)=0;
        end
    end
end
    