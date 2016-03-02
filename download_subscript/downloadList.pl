#!/usr/bin/perl

local $ENV{PATH} = "$ENV{PATH}:/usr/bin";

# modify Y.S.
# $usage = "usage $0 <list-file> <site> <key-file> <data_dir> \n";
$usage = "usage $0 <manifest-list-file> <key-file> <data_dir> \n";


# modify Y.S.
# if ($#ARGV != 3)
if ($#ARGV != 2)
{
    print $usage;
    exit;
}

# get commandline arguments
$listFile = shift;
# $source = shift; $ modify Y.S.
$credFile = shift;
$dataDir = shift;

if (! -e $listFile)
{
    print $usage;
    print "List File $listFile not found \n";exit;
}

if (! -e $credFile)
{
    print $usage;
    print "Key File $credFile not found \n";exit;
}

if (! -d $dataDir)
{
    print $usage;
    print "Download Directory $dataDir not found \n";exit;
}

# modify Y.S.
# @uuidList = &initFileList($listFile);
# $listSize = @uuidList;
@manifestList = &initFileList($listFile);
$listSize = @manifestList;

# number of total download attempts
# allows an average of 3 ttwmpts per UUID
$tryLimit = $listSize * 3;
$tryCount = 0;

# modify Y.S.
# foreach $uuid(@uuidList)
foreach $manifest (@manifestList)
{
    $tryCount++;
    if ($tryCount++ > $tryLimit)
    {
        print "Retry limit exceeded. Please check your list and try again later \n";
        exit;
    }

    # download data (with one retry)
    # modify Y.S.
    # $rc = &downloadObject($uuid, $source);
    $rc = &downloadObject($manifest);

    if ($rc)
    {
        # modify Y.S.
        # print "Failed downloading data for $uuid from $source \n";
        print "Failed downloading data for $manifest from cghub \n";

        # download failed so push the UUID back onto the list
        # push(@uuidList, $uuid);
        push (@manifestList, $manifest);
    }

    # always wait 10 seconds before next download attempt
    sleep 10;
}

exit;


sub downloadObject
{
    # modify Y.S.
    # my $uuid = $_[0];
    # my $site = $_[1];
    my $manifest = $_[0];

    # $dlUri = "$site/cghub/data/analysis/download/$uuid";

    # call gtdownload with:
    # -v		display progress every 5 seconds
    # --max-children 4	use 4 cpu cores for this download
    # -k 10		terminate the gtdownload attempt if no data is transferred within any 10 minute interval
    # -c <file>		path to the GNOS access token for the target repository
    # -p <directory>	path to the directory where the downloaded data is stored

    # modify Y.S.
    # my $rc = system "gtdownload -v --max-children 4 -k 10 -c $credFile -p $dataDir $dlUri";
    print "/home/w3varann/tools/gt_downloader/gtdownload -vv --max-children 4 -k 10 -d $manifest -c $credFile -p $dataDir\n";
    my $rc = system "/home/w3varann/tools/gt_downloader/gtdownload -vv --max-children 4 -k 10 -d $manifest -c $credFile -p $dataDir";

    if ($?)
    {
        # retry once
        # always wait 10 seconds before retrying
        sleep 10;
        print "ERROR downloading $uuid rc = $rc and error = $? Re-Trying...\n";

        # -k 20		allow 20 minutes to provide time to check existing data and resume in case of a partial download.
        # modify Y.S>
        # my $rc = system "gtdownload -v --max-children 4 -k 20 -c $credFile -p $dataDir $dlUri";
        print "/home/w3varann/tools/gt_downloader/gtdownload -vv --max-children 4 -k 20 -d $manifest -c $credFile -p $dataDir\n";
        my $rc = system "/home/w3varann/tools/gt_downloader/gtdownload -vv --max-children 4 -k 20 -d $manifest -c $credFile -p $dataDir";

        if ($?)
        {
            print "ERROR downloading $uuid rc = $rc and error = $? \n";
            return -1;
        }
    }

    return 0;
}




sub initFileList
{
    my $inputFile = shift;
    my @fileList = ();

    # open read close file
    open(DAT, "$inputFile") || die("Could not open input file! $inputFile");
    my @alllines=<DAT>;
    close(DAT);

    # strip out the tags leaving only uuid
    foreach $line (@alllines)
    {
        ($t1,$tag,$t3,$uuid,$nada)=split(/\s+/,$line);
        # check if cgquery output
        if ($tag eq 'analysis_id')
        {
            $newUuid = $uuid;
        }
        else
        {
            $newUuid = $line;
        }
        $newUuid =~ s/^\s+|\s+$//g;
        push(@fileList, $newUuid);
    }

    return @fileList;
}
