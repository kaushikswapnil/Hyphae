class Branch
{
   ArrayList<Node> m_Nodes;
   ArrayList<Branch> m_SubBranches;
   PVector m_CurrentTravelDirection;
   boolean m_ActiveGrowth;
   int m_NodesAddedSinceLastReorientation;
   
   Branch(Node startNode)
   {
     m_Nodes = new ArrayList<Node>();
     m_Nodes.add(startNode);
     m_SubBranches = new ArrayList<Branch>();
     
     m_CurrentTravelDirection = PVector.random2D();
     
     m_ActiveGrowth = true;
     
     m_NodesAddedSinceLastReorientation = 0;
   }
   
   Branch(Node startNode, PVector travelDir)
   {
     m_Nodes = new ArrayList<Node>();
     m_Nodes.add(startNode);
     m_SubBranches = new ArrayList<Branch>();
     
     m_CurrentTravelDirection = travelDir.get();
     m_CurrentTravelDirection.normalize();
     
     m_ActiveGrowth = true;
     
     m_NodesAddedSinceLastReorientation = 0;
   }
   
   Branch(ArrayList<Node> startingNodes, PVector travelDir)
   {
     m_Nodes = startingNodes;
     m_SubBranches = new ArrayList<Branch>();
     
     m_CurrentTravelDirection = travelDir.get();
     m_CurrentTravelDirection.normalize();
     
     m_ActiveGrowth = true;
     
     m_NodesAddedSinceLastReorientation = 0;
   }
   
   void Update()
   {
     if (m_ActiveGrowth)
     {
        ActiveGrowthUpdate(); 
     }
     
     TryBranching();
     
     for (Branch branch : m_SubBranches)
     {
        branch.Update(); 
     }
   }
   
   void Display()
   {
      pushMatrix();
      fill(0);
      for (int nodeIter = 0; nodeIter < m_Nodes.size(); ++nodeIter)
      {
         //m_Nodes.get(nodeIter).Display();
         float branchWidth = m_Nodes.get(nodeIter).m_Diameter*3/5;
         strokeWeight(branchWidth);
         if (nodeIter + 1 < m_Nodes.size())
         {
            //strokeWeight(4 * m_Nodes.get(nodeIter).m_Diameter/2);
            line(m_Nodes.get(nodeIter).m_Position.x, m_Nodes.get(nodeIter).m_Position.y, m_Nodes.get(nodeIter+1).m_Position.x, m_Nodes.get(nodeIter+1).m_Position.y); 
         }
      }
      popMatrix();
      
      for (Branch branch : m_SubBranches)
      {
         branch.Display(); 
      }      
   }
   
   void ActiveGrowthUpdate()
   {
     boolean shouldGrow = IsLesserOrEqualWithEpsilon(random(1), 0.5f);
     if (shouldGrow)
     {
       Node growNode = m_Nodes.get(m_Nodes.size()-1);
       float newDiameter = growNode.m_Diameter;
       
       //Adding a 5 percent chance to create a smaller node next
       if (IsLesserWithEpsilon(random(1.0), 0.05))
       {
          newDiameter *= 0.9; 
       }
       
       if (IsLesserWithEpsilon(newDiameter, g_MinNodeDiameter))
       {
          newDiameter = g_MinNodeDiameter; 
       }
       
       PVector newPos = PVector.add(growNode.m_Position, (PVector.mult(m_CurrentTravelDirection, (growNode.m_Diameter + newDiameter)/2)));
       
       if (CanAddNodeTo(newPos, newDiameter))
       {
         m_Nodes.add(new Node(newPos, newDiameter));
         ++m_NodesAddedSinceLastReorientation;
       }
       else
       {
         m_ActiveGrowth = false; //<>//
       }
     }
     
     if (m_NodesAddedSinceLastReorientation > g_NumNodeThresholdForBranchReorientation)
     {
       ReorientBranch();
     }
     else //try wobble
     {
       m_CurrentTravelDirection = GetPotentialWobbleDirection(m_CurrentTravelDirection);
     }
   }
   
   void TryBranching()
   {
     boolean shouldBranch = IsLesserOrEqualWithEpsilon(random(1), 0.03f) && m_Nodes.size() >= 2;
     
     if (shouldBranch)
     {
       int branchGrowthStartIndex = (int)random(m_Nodes.size()-1);

       Node branchGrowthNode = m_Nodes.get(branchGrowthStartIndex);
       
       PVector branchDirectionAtGrowthNode = PVector.sub(m_Nodes.get(branchGrowthStartIndex+1).m_Position, branchGrowthNode.m_Position);
       branchDirectionAtGrowthNode.normalize();
       //Iterate till max 
       for (int branchAttemptIter = 0; branchAttemptIter < 6; ++branchAttemptIter)
       {    
         PVector potentialReorientDir = GetPotentialReorientationDirection(branchDirectionAtGrowthNode);
         float newNodeDiameter = 0.8 * branchGrowthNode.m_Diameter;
         PVector newNodePos = PVector.add(branchGrowthNode.m_Position, (PVector.mult(potentialReorientDir, (branchGrowthNode.m_Diameter + newNodeDiameter)/2)));
         
         if (CanAddNodeTo(newNodePos, newNodeDiameter))
         {
           Node newNode = new Node(newNodePos, newNodeDiameter);
           ArrayList<Node> subBranchNodes = new ArrayList<Node>();
           subBranchNodes.add(branchGrowthNode);
           subBranchNodes.add(newNode);
           
           m_SubBranches.add(new Branch(subBranchNodes, potentialReorientDir));
           break; //Break loop if we have a new branch
         }
       }
     }
   }
   
   float GetClosestDistanceToBranchSurface(PVector fromPos)
   {
      float recordDist = 10000.0f;
     
      for(Node node : m_Nodes)
      {
        float surfDist = node.GetClosestDistanceToNodeSurface(fromPos);
        
        if (IsLesserWithEpsilon(surfDist, recordDist))
        {
           recordDist = surfDist; 
        } 
      }
      
      for(Branch branch : m_SubBranches)
      {
        float surfDist = branch.GetClosestDistanceToBranchSurface(fromPos);
        
        if (IsLesserWithEpsilon(surfDist, recordDist))
        {
           recordDist = surfDist; 
        } 
      }
      
      return recordDist;
   }
   
   void ReorientBranch()
   {
     m_CurrentTravelDirection = GetPotentialReorientationDirection(m_CurrentTravelDirection);
     m_NodesAddedSinceLastReorientation = 0;
   }
   
   PVector GetPotentialReorientationDirection(PVector currentBranchDir)
   {
     Node lastNode = m_Nodes.get(m_Nodes.size() - 1);
     float dirWeightage = lastNode.m_Diameter/2;
     return GetPotentialReorientationDirection(currentBranchDir, dirWeightage, dirWeightage);
   }
   
   PVector GetPotentialWobbleDirection(PVector currentBranchDir)
   {
     Node lastNode = m_Nodes.get(m_Nodes.size() - 1);
     float curDirWeightage = lastNode.m_Diameter/2;
     float randDirWeightage = lastNode.m_Diameter/6;
     return GetPotentialReorientationDirection(currentBranchDir, curDirWeightage, randDirWeightage);
   }
   
   PVector GetPotentialReorientationDirection(PVector currentBranchDir, float currentDirWeightage, float randomDirWeightage)
   {
     PVector randomDir = PVector.random2D();

     PVector wanderPointDisp = PVector.mult(currentBranchDir, currentDirWeightage);
     wanderPointDisp.add(randomDir.mult(randomDirWeightage));
     
     PVector potentialDirection = wanderPointDisp;
     potentialDirection.normalize();
     
     return potentialDirection;
   }
}
