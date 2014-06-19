<h2>eGRID to RDF</h2>

This code is used for converting the <a href="http://www.epa.gov/cleanenergy/energy-resources/egrid/index.html">eGRID dataset from the US EPA</a> into RDF, allowing for sophisticated queries to be run over the data.  The eGRID data is available from the US EPA as a series of Excel files for several years.  This is great for looking up facts for a single power plant for a single year, but this is not an ideal format if you want to do more extensive types of data mining.  

<h3>Instructions</h3>

eGRID.R downloads the relevant files from the US EPA eGRID website, and then merges the data for all the years for the plants, generators, and boilers into three separate CSV files.  Make sure that you have installed the required libraries which are listed at the top of the code.

After the R code is run, <a href="http://code.google.com/p/google-refine/">Google Refine</a> is used to map the data in the CSV files to RDF.  Make sure that you first have the <a href="http://refine.deri.ie/">RDF Refine extension</a> installed.

You probably want to increase the amount of memory available to Google Refine as it will be used to generate rather large files (~400M each).  If you're running from the command line, you need to do:
<pre>
export REFINE_MEMORY=2048M
./refine
</pre>

From there, load in the CSV files, and create a new project for each.  The json files in this repository are records of the <a href="http://code.google.com/p/google-refine/wiki/History">change history</a> that we use to map from the CSV data to RDF.  To use these, click on "Undo/Redo", then click on "Apply" and copy/paste the contents of the appropriate json file.  From there, the files can be exported as RDF, TTL, etc.  This may take several minutes.

<h3>Background</h3>
This code has been developed in our work on <a href="http://enipedia.tudelft.nl">enipedia.tudelft.nl</a>, which is an ongoing exploration of how sophisticated visualizations and data management techniques can help us to explore and get a better understanding of various energy and industry topics.  While there is a growing amount of data being made publicly available, the data is not always published in formats that make it easy to process and navigate.  The code here shows some of our efforts at fixing this.

<h3>Application Examples</h3>
The data is now in a graph format instead of a tabular format, which makes it easy to run queries that follow different pathways through the data.

The <a href="http://enipedia.tudelft.nl/wiki/Navajo_Powerplant">Navajo Generating Station</a> (scroll to bottom of link) has apprently installed a SO<sub>2</sub> scrubber within the past few years.  If you were working with the data in Excel spreadsheet form, in order to find this data, you would have to search through eight spreadsheets, among 4000-5000 rows and 150 columns.  

By converting the data to <a href="http://en.wikipedia.org/wiki/Resource_Description_Framework">RDF</a>, we are able to run <a href="http://en.wikipedia.org/wiki/SPARQL">SPARQL</a> queries and very efficiently retrieve various views of the data.  For example, by using the identifier in the ORISPL columns of the spreadsheets, the SPARQL query below (run at http://enipedia.tudelft.nl/extdata/sparql) will show all of the emissions for every year for that particular plant (<a href="http://enipedia.tudelft.nl/sparql?default-graph-uri=&query=PREFIX+rdf%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0D%0APREFIX+plant%3A+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%2FPlant%2F%3E%0D%0APREFIX+egridprop%3A+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%2Fprop%2F%3E%0D%0APREFIX+rdfs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0D%0Aselect+%3FemissionName+%3Famount+%3Fyear+from+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%3E+%7B%0D%0A++plant%3A4941+egridprop%3AAnnual_Emissions+%3Femissions+.%0D%0A++%3Femissions+egridprop%3AYear+%3Fyear+.+%0D%0A++%3Femissions+egridprop%3AAmount+%3Famount+.+%0D%0A++%3Femissions+rdfs%3Alabel+%3FemissionName+.+%0D%0A%7D+order+by+%3FemissionName+%3Fyear+&format=text%2Fhtml&timeout=0&debug=on">results</a>)

<pre>
PREFIX rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt;
PREFIX plant: &lt;http://enipedia.tudelft.nl/data/eGRID/Plant/&gt;
PREFIX egridprop: &lt;http://enipedia.tudelft.nl/data/eGRID/prop/&gt;
PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt;
select ?emissionName ?amount ?year from &lt;http://enipedia.tudelft.nl/data/eGRID&gt; {
  plant:4941 egridprop:Annual_Emissions ?emissions .
  ?emissions egridprop:Year ?year . 
  ?emissions egridprop:Amount ?amount . 
  ?emissions rdfs:label ?emissionName . 
} order by ?emissionName ?year 
</pre>

A raw view of the data available for this power plant can be seen <a href="http://enipedia.tudelft.nl/data/page/eGRID/Plant/4941">here</a> via the <a href="http://www4.wiwiss.fu-berlin.de/pubby/">Pubby</a> Linked Data Frontend.

<a href="http://enipedia.tudelft.nl/wiki/EGRID_Example_Queries">These example queries</a> show how electricity production across nearly every U.S. state is increasing, as is CO<sub>2</sub> emissions, however, the U.S. as a whole is decarbonizing in terms of CO<sub>2</sub> emissions per MWh of generation.  Each of the tables are generated via single quprees.  CO<sub>2</sub> emissions per generation output per state per year is found via the following query (<a href="http://enipedia.tudelft.nl/sparql?default-graph-uri=&query=PREFIX+rdf%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0D%0APREFIX+plant%3A+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%2FPlant%2F%3E%0D%0APREFIX+egridprop%3A+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%2Fprop%2F%3E%0D%0APREFIX+egrid%3A+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%2F%3E%0D%0APREFIX+rdfs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0D%0APREFIX+xsd%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%23%3E%0D%0Aselect+%3Fstate+%28sum%28%3FemissionAmount%29%2Fsum%28%3FgenAmount%29+as+%3Fintensity%29+%3Fyear1+from+%3Chttp%3A%2F%2Fenipedia.tudelft.nl%2Fdata%2FeGRID%3E+%7B%0D%0A++%3Fplant+rdf%3Atype+egrid%3APlant+.+%0D%0A++%3Fplant+egridprop%3AState_abbreviation+%3Fstate+.+%0D%0A++%3Fplant+egridprop%3AAnnual_Net_Generation+%3Fgeneration+.%0D%0A++%3Fgeneration+egridprop%3AYear+%3Fyear1+.+%0D%0A++%3Fgeneration+egridprop%3AAmount+%3FgenAmount+.+%0D%0A++%3Fplant+egridprop%3AAnnual_Emissions+%3Femissions+.%0D%0A++%3Femissions+rdfs%3Alabel+%22CO2%22+.+%0D%0A++%3Femissions+egridprop%3AYear+%3Fyear2+.+%0D%0A++filter%28xsd%3Adouble%28%3Fyear1%29+%3D+xsd%3Adouble%28%3Fyear2%29%29+.+%0D%0A++%3Femissions+egridprop%3AAmount+%3FemissionAmount+.+%0D%0A%7D+group+by+%3Fstate+%3Fyear1+order+by+%3Fstate+%3Fyear1&format=text%2Fhtml&timeout=0&debug=on">results</a>):

<pre>
PREFIX rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt;
PREFIX plant: &lt;http://enipedia.tudelft.nl/data/eGRID/Plant/&gt;
PREFIX egridprop: &lt;http://enipedia.tudelft.nl/data/eGRID/prop/&gt;
PREFIX egrid: &lt;http://enipedia.tudelft.nl/data/eGRID/&gt;
PREFIX rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt;
PREFIX xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt;
select ?state (sum(?emissionAmount)/sum(?genAmount) as ?intensity) ?year1 from &lt;http://enipedia.tudelft.nl/data/eGRID&gt; {
  ?plant rdf:type egrid:Plant . 
  ?plant egridprop:State_abbreviation ?state . 
  ?plant egridprop:Annual_Net_Generation ?generation .
  ?generation egridprop:Year ?year1 . 
  ?generation egridprop:Amount ?genAmount . 
  ?plant egridprop:Annual_Emissions ?emissions .
  ?emissions rdfs:label "CO2" . 
  ?emissions egridprop:Year ?year2 . 
  filter(xsd:double(?year1) = xsd:double(?year2)) . 
  ?emissions egridprop:Amount ?emissionAmount . 
} group by ?state ?year1 order by ?state ?year1
</pre>
