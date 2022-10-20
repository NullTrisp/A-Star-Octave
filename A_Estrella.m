pkg load image
clear all
struct_levels_to_print(0)

global image = imread("mapa2.jpg");
global binary = im2bw(image);
global openset = [];
global closedset = [];
img_size = size(binary);



#Point locations
startPointX = 1;
startPointY = 1;
global endPointX = 130;
global endPointY = 40;

rectangle_size = 1;

image(endPointY, endPointX, : ) = [0, 0, 255];

function z = createNode (x, y ,g, parent)
  global endPointX;
  global endPointY;
  z.x = x;
  z.y = y;
  z.g = g;
  z.dx = abs(z.x- endPointX);
  z.dy = abs(z.y - endPointY);
  z.h = z.dx + z.dy
  z.f = z.g + z.h;
  z.parent = parent;
endfunction

function node = getLeastFNode()
  global openset;
  [value, index] = min([openset().f]);
  node = openset(index);
  openset(index) = [];
endfunction

function value = isInClosedSet(node)
  global closedset;
  value = 0;
  for i = 1:size(closedset)(2)
      current = closedset(i);

      if current.x == node.x && current.y == node.y
        value = 1;
        break
      endif
    endfor
endfunction

function nodes = getNearNodes(node)
  global binary;
  nodes = [];
  normalValue = 1;
  diagonalValue = sqrt(2);

  upX = node.x;
  upY = node.y - 1;

  downX = node.x;
  downY = node.y + 1;

  leftX = node.x - 1;
  leftY = node.y;

  rightX = node.x + 1;
  rightY = node.y;

  upRightX = node.x + 1;
  upRightY = node.y - 1;

  downRightX = node.x + 1;
  downRightY = node.y + 1;

  upLeftX = node.x - 1;
  upLeftY = node.y - 1;

  downLeftX = node.x - 1;
  downLeftY = node.y + 1;

  if(upLeftX > 0 && upLeftY > 0 && binary(upLeftY, upLeftX) == 1)
    newNode = createNode(upLeftX, upLeftY, node.g + diagonalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode];
    endif
  endif

  if(upX > 0 && upY  > 0 && binary(upY, upX) == 1)
    newNode = createNode(upX, upY, node.g + normalValue, node);
    if isInClosedSet(newNode ) == 0
      nodes = [nodes, newNode ];
    endif
  endif

  if(upRightX > 0 && upRightY > 0 && binary(upRightY, upRightX) == 1)
    newNode = createNode(upRightX, upRightY, node.g + diagonalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode];
    endif
  endif

  if(rightX > 0 && rightY > 0 && binary(rightY, rightX) == 1)
    newNode = createNode(rightX, rightY, node.g + normalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode];
    endif
  endif

  if(downRightX > 0 && downRightY > 0 && binary(downRightY, downRightX) == 1)
    newNode = createNode(downRightX, downRightY, node.g + diagonalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode];
    endif
  endif

  if(downX > 0 && downY > 0 && binary(downY, downX) == 1)
    newNode = createNode(downX, downY, node.g + normalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode ];
    endif
  endif

  if(downLeftX > 0 && downLeftY > 0 && binary(downLeftY, downLeftX) == 1)
    newNode  = createNode(downLeftX, downLeftY, node.g + diagonalValue, node);
    if isInClosedSet(newNode) == 0
      nodes = [nodes, newNode ];
    endif
  endif

  if(leftX > 0 && leftY > 0 && binary(leftY, leftX) == 1)
    newNode  = createNode(leftX, leftY, node.g + normalValue, node);
    if isInClosedSet(newNode ) == 0
      nodes = [nodes, newNode ];
    endif
  endif
endfunction

function value = isInOpenSet(node)
  global openset;
  value = 0;
    for i = 1:size(openset)(2)
      current = openset(i);

      if current.x == node.x && current.y == node.y
        value = 1;
        break
      endif
    endfor
endfunction

function validateCurrentGValue(node)
  global openset;
  if size(openset)(2) > 0
    for i = size(openset)(2):1
      current = openset(i);

      if current.x == node.x && current.y == node.y
        if current.g > node.g
          openset(i) = [];
          openset = [openset, node];
        endif
        break
      endif
    endfor
  endif
endfunction

function paint(node, color)
  global image;
  image(node.y, node.x, : ) = color;
endfunction

function recursion(node)
  paint(node, [0, 100, 0]);
  if isstruct (node.parent) == 0
    if node.parent == 0
      return;
    endif
  endif
  recursion(node.parent);
endfunction

function getRoad()
  global closedset;
  lastNode = closedset(1, end);
  paint(lastNode, [0, 100, 0]);
  recursion(lastNode.parent);
endfunction

#1. Add first node to openset
global g = 0;
openset = [openset, createNode(startPointX, startPointY, g, 0)];

while isempty(openset) == 0
  #2. Get node with least F
  nodeWithLeastF = getLeastFNode();
  paint(nodeWithLeastF, [255, 0, 0]);

  if isInClosedSet(nodeWithLeastF) == 0
    closedset = [closedset, nodeWithLeastF];
  endif

  #3. Get 8 near workable nodes
  nearNodes = getNearNodes(nodeWithLeastF);
  #4. Check for each near node
  for i = 1:size(nearNodes)(2)
    # 4.1 If it is not in openset add it
    if isInOpenSet(nearNodes(i)) == 0
      openset = [openset, nearNodes(i)];
    # 4.2 If it is in openset check g value
    else
      validateCurrentGValue(nearNodes(i));
    endif
  endfor

  if nodeWithLeastF.x == endPointX && nodeWithLeastF.y == endPointY
    getRoad()
    imshow (image);
    break;
  endif
  imshow (image);
  pause(0.00005);
endwhile
