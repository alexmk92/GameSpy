<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=true">
</script>
<script type="text/javascript">

var geocoder;
var map;

// Create our base map object 
function initialize()
{
   geocoder = new google.maps.Geocoder();
   var latlng = new google.maps.LatLng(0,0);
   var mapOptions = { 
      zoom: 12,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
   }
   map = new google.maps.Map(document.getElementById("map"), mapOptions);
}

// Add the users point to the map
function addAddress() {

	// Get the users current location
	var location      = document.getElementById("P1_LOCATION").value;  // Users postcode
	var radius_size   = document.getElementById("P1_RADIUS").value;    // Users radius size in miles
	var search_radius;

	// Translate the users location onto the map
	geocoder.geocode({ 'address': location}, function(results, status) {
	   if(status == google.maps.GeocoderStatus.OK) {

	   	   // Center around the users location
	       map.setCenter(results[0].geometry.location);

	       // Place a marker where the user is situated
	       var marker = new google.maps.Marker({
	            map:map,
	            position: results[0].geometry.location
	       });

	        // configure the radius
	       	// Construct the radius circle
			search_radius = new google.maps.Circle({
				 center:location,
				 radius:20000,
				 strokeColor:"#0000FF",
				 strokeOpacity:0.8,
				 strokeWeight:2,
				 fillColor:"#0000FF",
				 fillOpacity:0.4
			});


	       // add the store points to the map
           addStores();
	   } 
	});
}

// Add each store to the map
function addStores() {
 	
 	// Get a reference to our results
 	var stores_table = document.getElementsByClassName("uReport");
 	var store_rows   = stores_table[0].tBodies[0].rows;
 	// Get the total number of rows we found in our result list
	var num_stores = store_rows.length;

	// Loop over the rows and get their post code, adding the address to the map each time
	for (i = 0; i < num_stores; i++) 
	{
		var location = store_rows[i].childNodes[3].textContent;
		
		// Translate the stores location onto the map
		geocoder.geocode({ 'address': location}, function(results, status) {
		   if(status == google.maps.GeocoderStatus.OK) {
		       var marker = new google.maps.Marker({
		            map:map,
		            position: results[0].geometry.location,
		       });
		       marker.setIcon('http://maps.google.com/mapfiles/ms/icons/blue-dot.png')
		   } 
		});
	}
}

</script>