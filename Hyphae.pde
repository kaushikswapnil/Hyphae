float g_MaxDistFromCenter = 300.0f;
PVector g_Center;
float g_MinNodeDiameter = 5.0f;
int g_NumNodeThresholdForBranchReorientation = 5;

ArrayList<Branch> g_ActiveBranches;

void setup()
{
  size(800,800);
  g_ActiveBranches = new ArrayList<Branch>();
  g_Center = new PVector(width/2, height/2);
}

void draw()
{
  background(255);
  for (Branch branch: g_ActiveBranches)
  { 
    branch.Update();
  }
  
  for (Branch branch: g_ActiveBranches)
  { 
    branch.Display();
  }
}

void mouseClicked()
{
  g_ActiveBranches.add(new Branch(new Node(new PVector(mouseX, mouseY), random(15) + g_MinNodeDiameter))); 
}

float GetDistanceFromCenter(PVector position)
{
  return g_Center.dist(position);
}

float GetDistanceToClosestSurface(PVector position)
{
   float recordDist = 10000.0f;
   
   for(Branch branch : g_ActiveBranches)
   {
      float surfDist = branch.GetClosestDistanceToBranchSurface(position);
        
      if (IsLesserWithEpsilon(surfDist, recordDist))
      {
         recordDist = surfDist; 
      } 
   }
   
   return recordDist;
}

boolean CanAddNodeTo(PVector position, float diameter)
{
   float distToClosestSurf = GetDistanceToClosestSurface(position);
   boolean hasSpaceToMakeNewNode = IsGreaterOrEqualWithEpsilon(distToClosestSurf, diameter/2);
   
   float distToCenter = GetDistanceFromCenter(position);
   boolean isWithinDrawRadius = IsLesserOrEqualWithEpsilon(distToCenter, g_MaxDistFromCenter);
   
   if (hasSpaceToMakeNewNode && isWithinDrawRadius)
   {
      return true; 
   }

   return false;
}

boolean IsNullWithEpsilon(float value)
{
  return abs(value - 0.0) <= EPSILON;
}

boolean IsGreaterWithEpsilon(float a, float b)
{
  return (a - b) > EPSILON;
}

boolean IsLesserWithEpsilon(float a, float b)
{
  return (a - b) < EPSILON;
}

boolean IsEqualWithEpsilon(float a, float b)
{
  return IsNullWithEpsilon(a-b); 
}

boolean IsGreaterOrEqualWithEpsilon(float a, float b)
{
   return IsGreaterWithEpsilon(a, b) || IsEqualWithEpsilon(a, b); 
}

boolean IsLesserOrEqualWithEpsilon(float a, float b)
{
   return IsLesserWithEpsilon(a, b) || IsEqualWithEpsilon(a, b); 
}
