$(document).ready(function(){
 $.ajax({
    'url' : '/session/current',
      'type' : 'get',
      'success' : function(data, textStatus, xhr){ 
       if(data.current_user.admin === false){
        $("#search-button").remove();
        $("#toggle-hamburger-menu").remove();
       }      
      },
      'error' : function(request,error)
      {

      }
  });
})