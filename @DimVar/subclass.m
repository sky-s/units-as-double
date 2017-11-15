function v = subclass(v)
% Convert DimVar to an appropriate subclass.


expos = round(v.exponents,5);
switch nnz(expos)
    case 0
        v = double(v);
    case 1
        singles = expos==1;
        if any(singles)
            switch find(singles)
                case 1
                    v = Length(double(v),expos);
                case 2
                    v = Mass(double(v),expos);
                case 3
                    v = Time(double(v),expos);
                case 5
                    v = Temperature(double(v),expos);
                case 9
                    v = Currency(double(v),expos);
            end
        end
        if expos(1) > 1
            switch expos(1)
                %         case 1
                %             vOut = Length(double(v),expos);
                case 2
                    v = Area(double(v),expos);
                case 3
                    v = Volume(double(v),expos);
            end
        end
    case 2
        if isequal(expos(1:3),[1 0 -1])
            v = Velocity(double(v),expos);
        end
    case 3
        if      isequal(expos(1:3),[1 1 -2])
            v = Force(double(v),expos);
        elseif  isequal(expos(1:3),[2 1 -2])
            v = Energy(double(v),expos);
        elseif  isequal(expos(1:3),[2 1 -3])
            v = Power(double(v),expos);
        elseif  isequal(expos(1:3),[-1 1 -2])
            v = Pressure(double(v),expos);
        end
end