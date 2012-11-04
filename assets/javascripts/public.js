// JavaScript Document
$(function() {
   $(".advanced_search").toggle(
        function () {
           $(".submenu").show();
  	 	 $(this).attr('class','advanced_search_expansion advanced_search');
        },
        function () {
           $(".submenu").hide();
  	 	 $(this).attr('class','advanced_search');
        }
      );
   $(".main_area table thead tr th").live( 'mouseover', function(e){     
         $(this).find('.arrow').show();    
   });
   $(".main_area table thead tr th").live('mouseout', function(e) {    
       $(this).find('.arrow').hide();    
   });
  //  $(".arrow").live('click', function(e) {    
  //       $(this).next().show();    
  // });


});


function showMe(thisObj,id){
     var objDiv=document.getElementById(id)
     objDiv.style.display=(objDiv.style.display=="none")?'':"none"
     document.onclick=function(e){
        var o = o || window.event || e;
        var obj=o.target || o.srcElement;
        if (obj!=objDiv &&obj!=thisObj)objDiv.style.display='none'
     }
}



