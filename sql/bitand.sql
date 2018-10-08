select level - 1 lvl,
       sign(bitand(power(2, 7), level - 1)) b7,
       sign(bitand(power(2, 6), level - 1)) b6,
       sign(bitand(power(2, 5), level - 1)) b5,
       sign(bitand(power(2, 4), level - 1)) b4,
       sign(bitand(power(2, 3), level - 1)) b3,
       sign(bitand(power(2, 2), level - 1)) b2,
       sign(bitand(power(2, 1), level - 1)) b1,
       sign(bitand(power(2, 0), level - 1)) b0
from   dual
connect by level < 102
