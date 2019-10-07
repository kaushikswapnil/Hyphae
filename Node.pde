class Node
{
   PVector m_Position;
   float m_Diameter;
   
   Node(PVector position, float diameter)
   {
      m_Position = position.get();
      m_Diameter = diameter;
   }
   
   void Display()
   {
      pushMatrix();
      fill(250, 0, 0);
      noStroke();
      ellipse(m_Position.x, m_Position.y, m_Diameter, m_Diameter);
      popMatrix();
   }
   
   float GetClosestDistanceToNodeSurface(PVector fromPos)
   {
      float radius = m_Diameter/2;
      float surfDist = m_Position.dist(fromPos) - radius;
      
      return surfDist;
   }
}
