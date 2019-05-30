
// Define SVG area dimensions
var svgWidth = 1000;
var svgHeight = 500;

// Define the chart's margins as an object
var margin = {
  top: 20,
  right: 40,
  bottom: 60,
  left: 100
};

// Define dimensions of the chart area
var width = svgWidth - margin.left - margin.right;
var height = svgHeight - margin.top - margin.bottom;

// Select body, append SVG area to it, and set the dimensions
var svg = d3
    .select("#scatter")
    .append("svg")
    .attr("height", svgHeight)
    .attr("width", svgWidth);

var chartGroup = svg.append("g")
    .attr("transform", `translate(${margin.left}, ${margin.top})`);

// Load data from data.csv
d3.csv("./assets/data/data.csv")
    .then(healthData => {
        // console.log(healthData)
        // Step 1: Parse Data/Cast as numbers
        // ==============================
        healthData.forEach(data => {
            data.poverty = +data.poverty
            data.obesity = +data.obesity
            // console.log(data.obesity)
        })
        // Step 2: Create scale functions
        // ==============================
        var xLinearScale = d3.scaleLinear()
        .domain([d3.min(healthData, d=> d.poverty)-1, d3.max(healthData, d => d.poverty)+1])
        .range([0, width]);

        var yLinearScale = d3.scaleLinear()
        .domain([d3.min(healthData, d=> d.obesity)-1, d3.max(healthData, d => d.obesity)+1])
        .range([height, 0]);

        // Step 3: Create axis functions
        // ==============================
        var bottomAxis = d3.axisBottom(xLinearScale);
        var leftAxis = d3.axisLeft(yLinearScale);

        // Step 4: Append Axes to the chart
        // ==============================
        chartGroup.append("g")
        .attr("transform", `translate(0, ${height})`)
        .call(bottomAxis);

        chartGroup.append("g")
        .call(leftAxis);

        // Step 5: Create Circles and Labels
        // ==============================
        var circlesLabel = chartGroup.selectAll("text")
        .data(healthData)
        .enter()
        .append("text")
        .text(d => d.abbr) // some labels missing on display, not sure why
        .attr("x", d => xLinearScale(d.poverty)-10)
        .attr("y", d => yLinearScale(d.obesity)+5)
        .attr("font-size", "14px");

        var circlesGroup = chartGroup.selectAll("circle")
        .data(healthData)
        .enter()
        .append("circle")
        .attr("cx", d => xLinearScale(d.poverty))
        .attr("cy", d => yLinearScale(d.obesity))
        .attr("r", "10")
        .attr("fill", "blue")
        .attr("opacity", ".50");

        // Step 6: Initialize tool tip
        // ==============================
        var toolTip = d3.tip()
        .attr("class", "tooltip")
        .offset([80, -60])
        .style("fill", "white") // not sure why font color is not changing
        .style("background-color", "gray")
        .html(function(d) {
            return (`${d.abbr}<br>Poverty: ${d.poverty}%<br>Obesity: ${d.obesity}%`);
        });

        // Step 7: Create tooltip in the chart
        // ==============================
        chartGroup.call(toolTip);

        // Step 8: Create event listeners to display and hide the tooltip
        // ==============================
        circlesGroup.on("mouseover", function(data) {
        toolTip.show(data, this);
        })
        // onmouseout event
        .on("mouseout", function(data, index) {
            toolTip.hide(data);
        });

        // Create axes labels
        chartGroup.append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 0 - margin.left + 40)
        .attr("x", 0 - (height / 2))
        .attr("dy", "1em")
        .attr("class", "axisText")
        .text("Obesity (%)");

        chartGroup.append("text")
        .attr("transform", `translate(${width / 2}, ${height + margin.top + 30})`)
        .attr("class", "axisText")
        .text("Poverty (%)");
    
    })
