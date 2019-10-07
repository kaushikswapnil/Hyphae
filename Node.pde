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
      fill(250, 0, 0);
      noStroke();
      ellipse(m_Position.x, m_Position.y, m_Diameter, m_Diameter);
   }
}
