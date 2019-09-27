closebox = () => {
  document.getElementById('card-alert').style.display = 'none'
}

// startx, starty, distx, disty
checkLine = (nx ,ny, dx, dy) => {
  turn = document.getElementById('status').innerText == 'whiteのターン' ? 'white' : 'black';
  if(getBoard(nx,ny).innerHTML == `<div class="${turn} stone"></div>`) return false
  while(true){
    // ボードから外れた
    if(!insideBoard(nx, ny))return false
    pos = getBoard(nx,ny)
    // から枠だった
    if(pos.innerHTML == '' || pos.innerHTML == '<div class="red stone"></div>')return false
    if(pos.innerHTML == `<div class="${turn} stone"></div>`){
      return true
    }
    nx += dx;
    ny += dy;
  }
}

checkStone = (x, y) => {
  flag = false
  turn = document.getElementById('status').innerText == 'whiteのターン' ? 'white' : 'black';
  for(var dx = -1; dx <= 1 ; dx ++){
    for(var dy = -1; dy <= 1 ; dy ++){
      if(dx == dy && dx == 0)continue;
      if(!insideBoard(x + dx) || !insideBoard(y + dy))continue;
      flag = checkLine(x + dx, y + dy, dx, dy) || flag
    }
  }
  const pos = getBoard(limitBoard(x), limitBoard(y))
  if(flag){
    pos.innerHTML = '<div class="red stone"></div>'
    return true
  } else{
    pos.innerHTML = ''
    return false
  }
}

// 置けるところ
checkBoard = () => {
  table = document.getElementsByTagName('table')[1]
  tr = table.getElementsByTagName('tr')
  let flag = false
  for(var i = 0 ; i < tr.length ; i ++  ){
    td  = tr[i].getElementsByTagName('td')
    for(var j = 0 ; j < td.length ; j ++ ){
      const pos = getBoard(j, i)
      if(pos.innerHTML == "" || pos.innerHTML == '<div class="red stone"></div>'){
        flag += checkStone(j, i)
      }
    }
  }
  console.log(flag)
  return flag
}
