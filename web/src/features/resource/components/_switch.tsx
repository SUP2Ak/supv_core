import React, { useState } from "react";
import { Box, Switch } from "@mantine/core";
import { ButtonsEditor } from "./_buttons";
import { _BooleanSwitchProps } from "../../../typings";

export const BooleanEdit: React.FC<_BooleanSwitchProps> = ({
	inputKey,
	label,
	description,
  currentValue,
  resource,
  file,
  navKey,
  index,
  setResourceData
}) => {
	const [isDisabled, setIsDisabled] = useState<boolean>(true);
  const [value, setValue] = useState<boolean>(currentValue);

	return (
		<Box
			sx={{
				backgroundColor: "rgba(255,255,255,0.035)",
				outline: "solid rgba(255,255,255, 0.2)",
				borderRadius: 2,
				margin: 5,
			}}
		>
			<Switch
        key={inputKey}
        label={label}
        description={description}
        checked={value}
        disabled={isDisabled}
        onChange={(e) => {
          setValue(e.currentTarget.checked);
        }}
        size="xs"
        m={5}
      />
      <ButtonsEditor
        inputKey={inputKey}
        resource={resource}
        file={file}
        value={value}
        setIsDisabled={setIsDisabled}
        isDisabled={isDisabled}
        index={index}
        navKey={navKey}
        setResourceData={setResourceData}
      />
		</Box>
	);
};
