function ConvertTo-Json20([object] $item){
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    $ps_js.maxJsonLength = 1024*1024*1024
    return $ps_js.Serialize($item)
}

function recurse {
	param($dir)

	Get-ChildItem -LiteralPath $dir | ForEach-Object {
		# Set up the sub-object
        $obj = @{}
		$children = @()
	} {
		# Add the items in this folder to the object
		if($_.PSIsContainer) {
			# Is folder, recurse
			$element = @{}
			$element.Add("fullname", $_.PSChildName)
			$element.Add("size", 0)
			$element.Add("children", @(recurse $_.PSPath))
			$children += $element
		} else {
			# Is file, add to tree
			if($_.Length -ge ($minSize)) { 
				$element = @{}
				$element.Add("size", $_.Length)
				$element.Add("fullname", $_.FullName)
				$children += $element
			}
		}
	} {
		# Return
		$children
	}
}

# Record the start time
$startTime = get-date
write-host "Start: $startTime"
$startTimestamp = Get-Date $startTime -format o | ForEach-Object {$_ -replace ":", "-"}

### Set up vars, may be set from AMP
# Directory to recurse through
if(!$dir) { $dir = "c:\" }
# Minimum file size to include (in bytes)
if(!$minSize) { $minsize = 2048 }

# Output file
$file = "c:\temp\diskreport-$env:computername-$startTimestamp.html"

# Create a root obj to hold the whole array
$rootobj = @{}


# Add the root dir to the tree
$rootobj.Add("fullname", $dir)
$rootobj.Add("size", 0)
$rootobj.Add("children", @(recurse $dir))

# Print timing info
$endTime = get-date
write-host "Start: $startTime"
write-host "End:   $endTime"
write-host "Time:  $(New-TimeSpan -Start $startTime -End $endTime)"

# Remove any old diskreports
Remove-Item "c:\temp\diskreport-*.html" -Force -ErrorAction SilentlyContinue

# Write timing info
Write-Output "<!-- Start: $startTime -->" | out-file -encoding UTF8 -append $file
Write-Output "<!-- End:   $endTime -->"   | out-file -encoding UTF8 -append $file
Write-Output "<!-- Time:  $(New-TimeSpan -Start $startTime -End $endTime) -->" | out-file -encoding UTF8 -append $file

Write-Output @"
<!-- adapted from http://jsfiddle.net/vis4/BrLaT/ -->
<!DOCTYPE html>
<html>
	<head>
		<title>$env:computername - $startTimestamp - Diskreport</title>
		<style type="text/css">
			body {
				font-family: sans-serif;
				font-size: 11px;
				margin: auto;
				position: relative;
				padding: 10px;
			}
			.node {
				border: solid 1px white;
				line-height: 0.95;
				overflow: hidden;
				position: absolute;
			}
			.node div {
				padding: 4px;
				white-space: pre;
			}
		</style>
		<script src="https://d3js.org/d3.v3.min.js"></script>
		<script src="https://cdn.filesizejs.com/filesize.min.js"></script>
		<script>
"@ | out-file -encoding UTF8 -append $file

# Write json tree
Write-Output "var tree=" | out-file -encoding UTF8 -append $file
#$rootobj | ConvertTo-Json -compress -depth 100 #| out-file -encoding UTF8 -append $file
ConvertTo-Json20($rootobj) | out-file -encoding UTF8 -append $file

Write-Output @"
			window.onload = function () {

				var width = innerWidth - 20,
					height = innerHeight - 20,
					color = d3.scale.category20c(),
					div = d3.select("body").append("div").style("position", "relative");

				var treemap = d3.layout.treemap()
					.size([width, height])
					.sticky(true)
					.value(function (d) {
						return d.size;
					});

				function filesize_gwm(d) {
					try {
						return filesize(d.size);
					} catch (e) {
						console.log(e.toString());
						console.log(d.name, d.size);
						return "";
					}
				}

				var node = div.datum(tree).selectAll(".node")
					.data(treemap.nodes)
					.enter()
					.append("div")
					.attr("class", "node")
					.attr("title", function (d) {
						return d.fullname + "\n" + filesize_gwm(d) + " (" + d.size + " B)";
					})
					.call(position)
					.style("background-color", function (d) {
						return color(d.fullname.split(/\./).pop().toLowerCase());
					});
				node.append('div')
					.text(function (d) {
						return d.children ? null : d.fullname.split(/\\/).pop() + "\n" + filesize_gwm(d);
					});

				function position() {
					this.style("left", function (d) {
						return d.x + "px";
					})
					.style("top", function (d) {
						return d.y + "px";
					})
					.style("width", function (d) {
						return Math.max(0, d.dx - 1) + "px";
					})
					.style("height", function (d) {
						return Math.max(0, d.dy - 1) + "px";
					});
				}
			};
		</script>
	</head>
	<body>
	</body>
</html>

"@ | out-file -encoding UTF8 -append $file
