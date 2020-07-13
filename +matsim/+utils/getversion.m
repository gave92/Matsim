function [major_version, minor_version, version_number] = getversion()
%GETVERSION Gets MATLAB version (e.g. R2015B)

persistent cachedMatlabVersion
if isempty(cachedMatlabVersion)
    cachedMatlabVersion = struct;
    version_string = version;
    tokens = regexp(version_string,'\(R([0-9]*)(a|b)\)', 'once', 'tokens'); % ['2011', 'b']
    cachedMatlabVersion.version_string = version_string;
    cachedMatlabVersion.version_number = sscanf(version_string,'%f',1);
    cachedMatlabVersion.major_version = str2double(tokens{1});
    cachedMatlabVersion.minor_version = tokens{2};
end

major_version = cachedMatlabVersion.major_version;
minor_version = cachedMatlabVersion.minor_version;
version_number = cachedMatlabVersion.version_number;

end
