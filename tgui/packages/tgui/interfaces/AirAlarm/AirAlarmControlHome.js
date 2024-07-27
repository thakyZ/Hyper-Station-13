import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button } from '../../components';

//  Home screen
// --------------------------------------------------------
export const AirAlarmControlHome = (props, context) => {
  const { act, data } = useBackend(context);
  const [currentPage, setCurrentPage] = useLocalState(context, "AirAlarmPage", "home");
  const {
    mode, atmos_alarm,
  } = data;
  return (
    <Fragment>
      <Button
        icon={atmos_alarm
          ? 'exclamation-triangle'
          : 'exclamation'}
        color={atmos_alarm && 'caution'}
        content="Area Atmosphere Alarm"
        onClick={() => act(atmos_alarm ? 'reset' : 'alarm')} />
      <Box mt={1} />
      <Button
        icon={mode === 3
          ? 'exclamation-triangle'
          : 'exclamation'}
        color={mode === 3 && 'danger'}
        content="Panic Siphon"
        onClick={() => act('mode', {
          mode: mode === 3 ? 1 : 3,
        })} />
      <Box mt={2} />
      <Button
        icon="sign-out-alt"
        content="Vent Controls"
        onClick={() => setCurrentPage("vents")} />
      <Box mt={1} />
      <Button
        icon="filter"
        content="Scrubber Controls"
        onClick={() => setCurrentPage("scrubbers")} />
      <Box mt={1} />
      <Button
        icon="cog"
        content="Operating Mode"
        onClick={() => setCurrentPage("modes")} />
      <Box mt={1} />
      <Button
        icon="chart-bar"
        content="Alarm Thresholds"
        onClick={() => setCurrentPage("thresholds")} />
    </Fragment>
  );
};
