// startx, starty, distx, disty
updateLine = (nx, ny, dx, dy, turn) => {
  console.log(nx, ny);
  while (true) {
    pos = getBoard(nx, ny);
    console.log(pos);
    if (pos.innerHTML == `<div class="${turn} stone"></div>`) {
      return true;
    }
    // updateStone(nx, ny, turn);
    updateStone(nx, ny, turn);
    console.log(pos);
    nx += dx;
    ny += dy;
  }
};

updateBoard = (x, y) => {
  console.log(x, y);
  count = 0;
  flag = false;
  turn =
    document.getElementById("status").innerText == "whiteのターン"
      ? "white"
      : "black";
  // updateStone(x,y,turn)
  updateStone(x, y, turn);
  for (var dx = -1; dx <= 1; dx++) {
    for (var dy = -1; dy <= 1; dy++) {
      if (dx == dy && dx == 0) continue;
      if (!insideBoard(x + dx) || !insideBoard(y + dy)) continue;
      if (checkLine(x + dx, y + dy, dx, dy)) {
        updateLine(x + dx, y + dy, dx, dy, turn);
      }
    }
  }
};

clearRed = () => {
  tr = document.getElementsByTagName("table")[1].getElementsByTagName("tr");
  for (var i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td");
    for (var j = 0; j < td.length; j++) {
      const pos = getBoard(j, i);
      if (pos.innerHTML == '<div class="red stone"></div>') {
        pos.innerHTML = "";
      }
    }
  }
};
