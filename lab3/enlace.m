classdef enlace < handle
    properties
        link
        resistencia
    end
    methods
        function self = enlace(varargin)
            self.link=varargin{1}
            self.resistencia=varargin{2}
        end
    end
end