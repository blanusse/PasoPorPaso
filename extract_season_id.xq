
declare variable $prefix external;

let $season := (//season[starts-with(@name, $prefix)])[1]
return
    if ($season) then
        string($season/@id)
    else
        ""