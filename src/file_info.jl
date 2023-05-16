"""
	$(SIGNATURES)

Returns file time since last modified (`mtime`) in seconds.
"""
function seconds_since_modified(fn)
    fTime = date_modified(fn);
    dt = Dates.value(Dates.now() - fTime);
    dt = round(dt / 1000);
    return dt
end


"""
	$(SIGNATURES)

Return file date modified for current time zone.
From:
https://discourse.julialang.org/t/how-to-consider-the-timezone-in-unix2datetime/90179/3
"""
function date_modified(fn)
    isfile(fn) || error("`$fn` is not a file");
    # This is Greenwich time
    dt = unix2datetime(mtime(fn));
    zdt = ZonedDateTime(dt, tz"UTC");
    zdt = astimezone(zdt, localzone())
    return DateTime(zdt)
end

# -----------------