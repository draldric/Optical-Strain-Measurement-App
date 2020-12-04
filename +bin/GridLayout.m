classdef GridLayout < handle
   properties
       bSize = []
       nSize = []
   end
   methods
       function [this] = GridLayout(n,b)
           if length(n)==1
               n = [n,n];
           end
           if length(b)==1
               b = [b,b];
           end
           this.bSize = b;
           this.nSize = ([1,1] - b.*(n+1))./n;
       end
       function [Position] = getPosition(this,n,m)
           Position(1) = n(1)*this.bSize(1)...
               +(n(1)-1)*this.nSize(1);
           Position(2) = m(1)*this.bSize(2)...
               +(m(1)-1)*this.nSize(2);
           Position(3) = abs(n(end)-n(1))*this.bSize(1)...
               +(abs(n(end)-n(1))+1)*this.nSize(1);
           Position(4) = abs(m(end)-m(1))*this.bSize(2)...
               +(abs(m(end)-m(1))+1)*this.nSize(2);
       end
   end
end
