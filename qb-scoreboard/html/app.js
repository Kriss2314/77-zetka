QBScoreboard = {};

$(document).ready(function () {
  window.addEventListener("message", function (event) {
    switch (event.data.action) {
      case "open":
        QBScoreboard.Open(event.data);
        break;
      case "close":
        QBScoreboard.Close();
        break;
    }
  });
});

QBScoreboard.Open = function (data) {
  $(".scoreboard").fadeIn(150).css('display', 'flex');
  $("#players").html(data.players);
  $("#total").html(data.maxPlayers);

  $.each(data.requiredCops, function (i, category) {
    var beam = $(".robbery-list").find('[data-type="' + i + '"]');
    var status = $(beam).find(".robbery-check");

    if (category.busy) {
      $(status).html('<i class="fas fa-clock"></i>');
    } else if (data.currentCops >= category.minimum) {
      $(status).html('<i class="fas fa-check"></i>');
    } else {
      $(status).html('<i class="fas fa-times"></i>');
    }
  });
};

QBScoreboard.Close = function () {
  $(".scoreboard").fadeOut(150);
};
