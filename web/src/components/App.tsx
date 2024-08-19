import React, { useState } from "react";
import { debugData } from "../utils/debugData";

// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

const App: React.FC = () => {
  return (
    <div>
      
    </div>
  );
};

export default App;
