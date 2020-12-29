function varargout = outselect(index,func,varargin)
%OUTSELECT  Select output arguments of a function.
%   OUTSELECT(I,FUNCTION,P1,P2,...) returns one or more of the outputs,
%   as selected by the integer(s) in vector I, resulting from the
%   function call FUNCTION(P1,P2,...). FUNCTION can be a handle or
%   anonymous function. 
%
%   OUTSELECT(I,FUNCTION) creates a callable form of FUNCTION that always
%   returns outputs of the original as specified by I.
%
%   Examples:
%
%     >> str = 'deacb';  [s,idx] = sort(str)
%     s =
%     abcde
%     idx = 
%          3     5     4     1     2
%
%     >> [idx,s] = outselect([2 1],@sort,str)
%     idx = 
%          3     5     4     1     2
%     s =
%     abcde
%
%     >> argmin = outselect(2,@min);
%     >> argmin(str)
%
%     ans = 
%          3
%
%   See also FUNCTION_HANDLE.
%
%   Copyright 2005 by Tobin Driscoll.
% Revision: 24 June 2005.
if isempty(varargin)   % return the callable nested function
  varargout{1} = @do_it;
else                   % apply the nested function once
  [varargout{1:nargout}] = do_it(varargin{:});
end
  function varargout = do_it(varargin)
  [allout{1:max(index)}] = func(varargin{:});
  varargout = allout(index);
  end
end
