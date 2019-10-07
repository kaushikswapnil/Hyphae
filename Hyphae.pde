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
  g_ActiveBranches.add(new Branch(new Node(new PVector(mouseX, mouseY), random(50) + g_MinNodeDiameter))); 
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
        
      if (surfDist < recordDist)
      {
         recordDist = surfDist; 
      } 
   }
   
   return recordDist;
}

boolean CanAddNodeTo(PVector position, float diameter)
{
   float distToClosestSurf = GetDistanceToClosestSurface(position);
   boolean hasSpaceToMakeNewNode = (distToClosestSurf >= diameter/2);
   
   float distToCenter = GetDistanceFromCenter(position);
   boolean isWithinDrawRadius = (distToCenter < g_MaxDistFromCenter);
   
   if (hasSpaceToMakeNewNode && isWithinDrawRadius)
   {
      return true; 
   }

   return false;
}
