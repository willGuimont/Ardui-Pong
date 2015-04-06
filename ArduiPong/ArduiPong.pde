import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
int analogPin1 = 1;
int analogPin2 = 2;

int ballSize = 13;

int ScreenHeight = 500;
int ScreenWidth = 1000;

int xPlayer1 = 2 * ballSize;
int yPlayer1 = ScreenHeight / 2;

int xPlayer2 = ScreenWidth - 4 * ballSize;
int yPlayer2 = yPlayer1;

int scorePlayer1 = 0;
int scorePlayer2 = 0;

int paddleHeight = 5 * ballSize;
int paddleWidth = 2 * ballSize;

int middle = ScreenWidth/2 - 13;

float xBall = middle;
float yBall = ScreenHeight/2;

float xBallMouv = randomXBallMouv();
float yBallMouv = randomYBallMouv();

int ballSpeed = 10;

PFont rosesAreFF0000;

boolean start = false;

void setup()
{
  size(ScreenWidth,ScreenHeight);
  rosesAreFF0000 = createFont("RosesareFF0000.ttf", paddleHeight);
  textFont(rosesAreFF0000);
  arduino = new Arduino(this, Arduino.list()[1]);
  stroke(255,255,255);
}

void mouseClicked()
{
  start = true;
}

void draw()
{
    drawField();
    playersMovements();
  if (start){
    ballMouvements();
  }
  if (scorePlayer1 >= 5){
    background(0,0,0);
    text("Player 1 won!!!", middle - 4 * paddleHeight - paddleHeight / 2, ScreenHeight/2);
    start = false;
  }
  if (scorePlayer2 >= 5){
    background(0,0,0);
    text("Player 2 won!!!", middle - 4 * paddleHeight - paddleHeight / 2, ScreenHeight/2);
    start = false;
  }
}

void playersMovements()
{ 
  yPlayer1 = int ((ScreenHeight - 2 * ballSize) * arduino.analogRead(analogPin1) / 1023); //1023 max value returned by analogRead);
  yPlayer2 = int ((ScreenHeight - 2 * ballSize) * (arduino.analogRead(analogPin2) - 47) / 936); // Because potentiometer...
  verifications();
  rect(xPlayer1, yPlayer1, paddleWidth, paddleHeight);
  rect(xPlayer2, yPlayer2, paddleWidth, paddleHeight);
}

void ballMouvements()
{
  rect(xBall, yBall, ballSize, ballSize);
  //collisionBallPlayer1();
  //collisionBallPlayer2();
  xBall += xBallMouv * ballSpeed;
  yBall += yBallMouv * ballSpeed;
  ballOutBound();
  ballCollision();
  
}

void drawField()
{
 background(0,0,0); 
 
 for (int i = 2 * ballSize; i < ScreenHeight; i = i + 2 * ballSize)
 {
   rect(middle, i, ballSize, ballSize);
 }
 
 rect (0,0, ScreenWidth + 5, ballSize);
 rect (0, ScreenHeight - ballSize, ScreenWidth + 5, ballSize);
 
 text(scorePlayer1, middle - paddleHeight , ballSize * 30 / 4);
 text(scorePlayer2, middle + paddleHeight - 2 * ballSize, ballSize * 30 / 4);
 
}

float randomXBallMouv(){
  float tmp = 0;
  while (tmp > -0.25f && tmp < 0.25f || tmp > 0.65 || tmp < -0.65)
    tmp = random(3) - 1;
  return tmp;
}

float randomYBallMouv(){
  float tmp = 0;
  while (tmp > -0.2f && tmp < 021f)
    tmp = random(3) - 1;
  return tmp;
}

void ballOutBound()
{
  if (xBall < 0 ){
    scorePlayer2++;
    resetBall();
  }
  else if (xBall + ballSize > ScreenWidth){
    scorePlayer1++;
    resetBall();
  }
}

void resetBall(){
    xBall = middle;
    yBall = ScreenHeight/2;

    xBallMouv = randomXBallMouv();
    yBallMouv = randomYBallMouv();
    
    ballSpeed = 10;
}

void ballCollision()
{
  if (collisionBallPlayer1() || collisionBallPlayer2())
    {
      xBallMouv = -xBallMouv;
      ballSpeed += 3;
    }
    if (collisionBallUpperWall() || collisionBallDownWall())
    {
      yBallMouv = -yBallMouv;
    }
    while (collisionBallPlayer1()){
    if (xBall < xPlayer1 + paddleWidth)
      xBall += 1;
    if (xBall + ballSize > xPlayer1)
      xBall += 1;
    /*
    if (yBall < yPlayer1 + paddleHeight)
      yBall += 1;
    if (yBall + ballSize > yPlayer1)
      yBall += 1;
    */
  }
  while (collisionBallPlayer2()){
    if (xBall < xPlayer2 + paddleWidth)
      xBall -= 1;
    if (xBall + ballSize > xPlayer2)
      xBall -= 1;
    /*
    if (yBall < yPlayer2 + paddleHeight)
      yBall -= 1;
    if (yBall + ballSize > yPlayer2)
      yBall -= 1;
    */
  }
  while (collisionBallUpperWall()){
    /*
    if (xBall < xPlayer2 + paddleWidth)
      xBall -= 1;
    if (xBall + ballSize > xPlayer2)
      xBall -= 1;
    */
    if (yBall < yPlayer2 + paddleHeight)
      yBall += 1;
    if (yBall + ballSize > yPlayer2)
      yBall += 1;
  }
  while (collisionBallDownWall()){   
    /*
    if (xBall < xPlayer2 + paddleWidth)
      xBall -= 1;
    if (xBall + ballSize > xPlayer2)
      xBall -= 1;
    */
    if (yBall < yPlayer2 + paddleHeight)
      yBall -= 1;
    if (yBall + ballSize > yPlayer2)
      yBall -= 1;
  }
}

boolean collisionBallUpperWall(){
   //rect (0,0, ScreenWidth + 5, ballSize);
   return (yBall < ballSize);
}

boolean collisionBallDownWall(){
  //rect (0, ScreenHeight - ballSize, ScreenWidth + 5, ballSize);
  return (yBall + ballSize > ScreenHeight - ballSize);
}

boolean collisionBallPlayer1(){
  return !(xBall > xPlayer1 + paddleWidth || xBall + ballSize < xPlayer1 ||
           yBall > yPlayer1 + paddleHeight || yBall + ballSize < yPlayer1);
}

boolean collisionBallPlayer2(){
  return !(xBall > xPlayer2 + paddleWidth || xBall + ballSize < xPlayer2 ||
           yBall > yPlayer2 + paddleHeight || yBall + ballSize < yPlayer2);
}

void verifications()
{
  int minBound = ballSize;
  int maxBound = ScreenHeight - paddleHeight - ballSize;
  if (yPlayer1 < minBound)
  {
    yPlayer1 = minBound;
  }
  if (yPlayer1 > maxBound)
  {
    yPlayer1 = maxBound;
  }
  if (yPlayer2 < minBound)
  {
    yPlayer2 = minBound;
  }
  if (yPlayer2 > maxBound)
  {
    yPlayer2 = maxBound;
  }
}

