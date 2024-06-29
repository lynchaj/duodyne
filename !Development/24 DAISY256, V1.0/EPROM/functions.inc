                save
                listing off
;user-defined functions
hi          function x,(x>>8)&255
lo          function x,x&255
odd         function x,(x&1)=1
even        function x,(x&1)=0                

                restore