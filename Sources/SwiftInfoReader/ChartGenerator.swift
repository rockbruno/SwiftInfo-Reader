import Foundation

struct Chart {
    func generate(info: [ProviderInfo]) -> String {
        let lastRunProject = info.flatMap { $0.runs }.map { $0.project }.max {
            ($0.timestamp ?? -1) < ($1.timestamp ?? -1)
        }
        let divs = info.map { #"<div id="\#($0.key)"></div>"# }.joined(separator: "<br>\n")
        let methodNames = info.map { "\($0.key)();" }.joined(separator: "\n")
        let methods = info.map(method).joined(separator: "\n")
        let date: String = {
            guard let timestamp = lastRunProject?.timestamp else {
                return "?"
            }
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: date)
        }()
        return """
        <html>
        <head>
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript">
            google.charts.load('current', {packages: ['corechart', 'line']});
            google.charts.setOnLoadCallback(drawChart);
            function drawChart() {
                \(methodNames)
            }
            \(methods)
        </script>
        </head>
        <body>
        <h1>SwiftInfo results for \(lastRunProject?.target ?? "(No project name)")</h1>
        <p>Most recent version: \(lastRunProject?.description ?? "(No project description)")</p>
        <p>Timestamp: \(date)</p>
        <br>
            \(divs)
        </body>
        </html>
        """
    }

    func method(for info: ProviderInfo) -> String {
        func tooltip(forRun run: Run) -> String {
            return "Version: \(run.project.versionString) (\(run.project.buildNumber))\\nValue: \(run.stringValue)"
        }
        let rows = info.runs.map { #"["\#($0.project.versionString)", \#($0.value), "\#(tooltip(forRun: $0))", "color: \#($0.color)"]"# }.joined(separator: ",")
        return """
        function \(info.key)() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Version');
            data.addColumn('number', '\(info.description)');
            data.addColumn({type:'string', role:'tooltip'});
            data.addColumn({type:'string', role:'style'});
            data.addRows([
                \(rows)
            ]);
            var options = {
                title: '\(info.description)',
                lineWidth: 4,
                pointsVisible: true,
                pointSize: 8,
                tooltip: {
                    isHtml: true,
                    showColorCode: true,
                },
                legend: {
                    position: "none"
                }
            };

            var chart = new google.visualization.LineChart(document.getElementById('\(info.key)'));
            chart.draw(data, options);
        }
        """
    }
}
