function convert_file(inFile, outFile; resolution = 200)
    sDevice = sdevice_from_path(outFile);
    run(`gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH   -sOutputFile="$outFile"  -sDEVICE=$sDevice -r$(resolution)  -dTextAlphaBits=4 -dGraphicsAlphaBits=4  -dUseCIEColor  -dUseTrimBox   -dFirstPage=1   -dLastPage=1   $inFile`);
end

function sdevice_from_path(outFile)
    _, fExt = splitext(outFile);
    if fExt == ".png"
        sDevice = "pngalpha";
    elseif fExt == ".jpg"
        sDevice = "jpeg";
    else
        error("Unknown extension $fExt");
    end
    return sDevice
end

# --------------------