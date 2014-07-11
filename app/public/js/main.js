$(document).ready(function(){

	// Tabs
	$('#add-connection-tab').click(function(){
		switchTabsToConnection();
	});

	$('#add-node-tab').click(function(){
		switchTabsToNode();
	});

	function switchTabsToNode(){
		$('#add-node-tab').addClass('selected');
		$('#add-connection-tab').removeClass('selected');
		$('.connection').addClass('hidden');
		$('.node').removeClass('hidden');
	}

	function switchTabsToConnection(){
		$('#add-connection-tab').addClass('selected');
		$('#add-node-tab').removeClass('selected');
		$('.node').addClass('hidden');
		$('.connection').removeClass('hidden');
	}

	// Buttons

	// Add Node
	$('#cancel-node').click(function(){
		$('#node-name').removeClass('red');
		$('.node > input[type="text"]').val("");
	});

	$('#add-node').click(function(){
		if($('#node-name').val() == ""){
			$('#node-name').addClass('red');
		}
		else {
			$('#node-name').removeClass('red');
			console.log($('.node > input[type="text"]').val());
			//send data to server
			$('.node > input[type="text"]').val("");
		}
	});

	$('#add-connection-node').click(function(){
		if($('#node-name').val() == ""){
			$('#node-name').addClass('red');
		}
		else {
			console.log($('.node > input[type="text"]').val());
			// send data to server

			$('#source-node-name').val($('#node-name').val());
			$('.node > input[type="text"]').val("");
			switchTabsToConnection();
		}
	});


	// Add Connection
	$('#cancel-connection').click(function(){
		$('.connection > input[type="text"]').removeClass('red');

		$('.connection > input[type="text"]').val("");
	});

	$('#add-connection').click(function(){
		var validated = true;
		if($('#connection-name').val() == ""){
			validated = false;
			$('#connection-name').addClass('red');
		}

		if($('#source-node-name').val() == ""){
			validated = false;
			$('#source-node-name').addClass('red');
		}

		if($('#destination-node-name').val() == ""){
			validated = false;
			$('#destination-node-name').addClass('red');
		}

		if(validated) {
			console.log($('.connection > input[type="text"]').val());
			//send data to server
			$('.connection > input[type="text"]').removeClass('red');
			$('.connection > input[type="text"]').val("");
		}
	});
	
});