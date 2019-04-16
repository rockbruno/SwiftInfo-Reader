import Foundation

struct Chart {
    func generate(info: [ProviderInfo]) -> String {
        let divs = info.map { #"<div id="\#($0.key)"></div>"# }.joined(separator: "<br>\n")
        let methodNames = info.map { "\($0.key)();" }.joined(separator: "\n")
        let methods = info.map(method).joined(separator: "\n")
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
            \(divs)
        </body>
        </html>
        """
    }

    func method(for info: ProviderInfo) -> String {
        let rows = info.runs.map { #"["\#($0.runDescription)", \#($0.value), "\#($0.runDescription): \#($0.tooltip)", "color: \#($0.color)"]"# }.joined(separator: ",")
        return """
        function \(info.key)() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Version');
            data.addColumn('number', 'Value');
            data.addColumn({type:'string', role:'tooltip'});
            data.addColumn({type:'string', role:'style'});
            data.addRows([
                \(rows)
            ]);
            var options = {
                title: '\(info.description)',
                lineWidth: 4,
                pointsVisible: true
            };

            var chart = new google.visualization.LineChart(document.getElementById('\(info.key)'));
            chart.draw(data, options);
        }
        """
    }
}
