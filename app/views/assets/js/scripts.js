document.addEventListener('DOMContentLoaded', function() {
    const collapseButtons = document.querySelectorAll('.collapse-button');
    const collapsibleContents = document.querySelectorAll('.collapsible-content');
  
    collapseButtons.forEach((button, index) => {
      button.addEventListener('click', function() {
        collapsibleContents[index].classList.toggle('show');
      });
    });
  });

script(type="text/javascript").
   $(document).ready(function() {
     $(".collapse-button").on("click", function() {
       $(this).next(".collapsible-content").slideToggle();
     });
   });
